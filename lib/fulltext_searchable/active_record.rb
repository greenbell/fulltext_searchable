# coding: utf-8

module FulltextSearchable
  ##
  # == 概要
  # ActiveRecord::Baseを拡張するモジュール
  #
  module ActiveRecord # :nodoc:
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
    end
    #
    # ActiveRecord::Baseにextendされるモジュール
    #
    module ClassMethods 
      ##
      # 全文検索機能を有効にする。
      #
      # ==== columns
      # 全文検索の対象とするカラムを指定。
      #
      # ==== 例:
      #   fulltext_searchable :title, :body
      #
      def fulltext_searchable(*args)
        cattr_accessor  :fulltext_columns

        self.fulltext_columns = Array.wrap(args)

        condition = '#{FulltextIndex.create_key(self)}'
        class_eval <<-EOV
        has_one :fulltext_index, {
          :as => :item,
          :dependent => :destroy,
          :conditions => ['`key` = ?', '#{condition}']
        }

        include FulltextSearchable::ActiveRecord::Behaviors

        after_save       :save_fulltext_index
        EOV
      end
    end
    #
    # 各モデルにincludeされるモジュール
    #
    module Behaviors
      extend ActiveSupport::Concern

      module ClassMethods
        ##
        # 各モデルに対し全文検索を行う。
        #
        def fulltext_match(phrase)
          FulltextIndex.match(phrase, :model => self)
        end
      end

      module InstanceMethods
        ##
        # after_saveにフック。
        #
        def save_fulltext_index
          if self.fulltext_index
            FulltextIndex.update(self)
          else
            self.create_fulltext_index :key => FulltextIndex.create_key(self), :text => fulltext_keywords
          end
        end

        ##
        # レコードの内容を全文検索インデックス用に変換
        #
        def fulltext_keywords
          arr_text = Array.wrap(FulltextSearchable.to_model_keyword(self.class.name))
          arr_text.push(collect_fulltext_keywords(self, fulltext_columns))
          arr_text.flatten.join(' ')
        end

        protected

        def collect_fulltext_keywords(target, columns, strip_tags=false)
          result = []
          return result unless target
          if target.is_a? Array
            target.each{|i| result.push(collect_fulltext_keywords(i, columns))}
          else
            result = []
            result.push(FulltextSearchable.to_item_keyword(target)) unless strip_tags
            columns.each do |column|
              if column.is_a? Hash
                column.each do |k,v|
                  if k.to_s.downcase == 'html' || k.to_s.downcase == 'html_columns'
                    result.push(collect_fulltext_keywords(target, Array.wrap(v), true))
                  else
                    result.push(collect_fulltext_keywords(target.send(k), Array.wrap(v)))
                  end
                end
              else
                if strip_tags
                  result.push(target.send(column.to_s).to_s.gsub(/<[^>]*>/ui,''))
                else
                  result.push(target.send(column.to_s).to_s)
                end
              end
            end
          end
          result
        end
      end
    end
  end
end

