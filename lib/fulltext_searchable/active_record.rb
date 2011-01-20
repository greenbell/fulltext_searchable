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
      #   fulltext_searchable [:title, :body]
      # 
      def fulltext_searchable(columns, options={})
        cattr_accessor  :fulltext_columns

        self.fulltext_columns = Array.wrap(columns).map!{|item| item.to_sym }

        class_eval <<-EOV
        has_one :fulltext_index, :as => :item, :dependent => :destroy

        include FulltextSearchable::ActiveRecord::InstanceMethods

        after_save       :save_fulltext_index
        EOV
      end
    end
    #
    # 各モデルにincludeされるモジュール
    #
    module InstanceMethods
      #
      # after_saveにフック。
      #
      def save_fulltext_index
        unless self.fulltext_index
          self.fulltext_index = FulltextIndex.new
        end
        self.fulltext_index.text = fulltext_keywords
        self.fulltext_index.save
      end
      def fulltext_keywords
        text = FulltextSearchable.to_model_keyword(self.class.name)
        fulltext_columns.each do |column|
          if column.is_a? Proc
            text += ' ' + column.call.to_s
          else
            text += ' ' + self[column].to_s
          end
        end
        text
      end
    end
  end
end

