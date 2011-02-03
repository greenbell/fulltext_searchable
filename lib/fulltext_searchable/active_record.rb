# coding: utf-8
require 'htmlentities'

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
      def fulltext_searchable(*args, &block)
        cattr_accessor  :fulltext_columns, :fulltext_keyword_proc

        self.fulltext_columns = Array.wrap(args)
        self.fulltext_keyword_proc = block

        condition = '#{FulltextIndex.create_key(self)}'
        class_eval <<-EOV
        has_one :fulltext_index, {
          :as => :item,
          :dependent => :destroy,
          :conditions => ['`key` = ?', '#{condition}']
        }

        include FulltextSearchable::ActiveRecord::Behaviors

        after_commit       :save_fulltext_index
        EOV
      end
      ##
      # 全文検索対応モデルかどうかを返す。
      #
      def fulltext_searchable?
        self.ancestors.include?(
          ::FulltextSearchable::ActiveRecord::Behaviors::InstanceMethods)
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

        ##
        # eager loadのために全文検索対応モデルが依存する他のモデルを返す。
        #
        def fulltext_dependent_models(columns=nil)
          columns ||= fulltext_columns
          if columns.is_a? Hash
            columns = Array.wrap(columns)
          end
          if columns.is_a? Array
            result = []
            columns.flatten!
            columns.each do |i|
              if i.is_a?(Hash)
                i.each do |k,v|
                  if v.is_a?(Hash) || v.is_a?(Array)
                    r = fulltext_dependent_models(v)
                    if r
                      result.push({k=>r})
                    else
                      result.push(k)
                    end
                  elsif v.to_s.downcase != 'html'
                    result.push(k)
                  end
                end
              end
            end
            case result.count
            when 0
              nil
            when 1
              result.first
            else
              result
            end
          else
            nil
          end
        end
      end

      module InstanceMethods
        ##
        # after_commitにフック。
        #
        def save_fulltext_index
          if self.fulltext_index
            FulltextIndex.update(self)
          else
            self.create_fulltext_index(
              :key => FulltextIndex.create_key(self),
              :text => fulltext_keywords
            )
          end
        end

        ##
        # レコードの内容を全文検索インデックス用に変換
        #
        def fulltext_keywords
          [
            FulltextSearchable.to_model_keyword(self.class.name),
            FulltextSearchable.to_item_keyword(self),
          ].tap{|a| a.push(fulltext_keyword_proc.call) if fulltext_keyword_proc }.
            concat(collect_fulltext_keywords(self, fulltext_columns)).
            flatten.join(' ')
        end

        protected

        def collect_fulltext_keywords(target, columns)
          result = []
          return result unless target
          if columns.is_a? Hash
            columns = Array.wrap(columns)
          end
          unless columns.is_a? Array
            return result.push(target.send(columns).to_s)
          end
          columns.flatten!
          columns.each do |column|
            if column.is_a? Hash
              column.each do |k,v|
                if v.to_s.downcase == 'html'
                  result.push(
                    HTMLEntities.decode_entities(
                      target.send(k.to_s).to_s.gsub(/<[^>]*>/ui,'')
                    ).gsub(/[ \s]+/u, ' ') # contains &nbsp;
                  )
                else
                  Array.wrap(target.send(k)).each do |t|
                    result.concat([
                      FulltextSearchable.to_item_keyword(t),
                      collect_fulltext_keywords(t, v)
                    ])
                  end
                end
              end
            else
              result.push(collect_fulltext_keywords(target, column))
            end
          end
          result.flatten
        end
      end
    end
  end
end

