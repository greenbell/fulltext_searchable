# coding: utf-8

require 'digest/md5'

##
# == 概要
# 全文検索インデックスとして機能するモデル。
#
class FulltextIndex < ActiveRecord::Base
  set_primary_key :_id
  after_create :set_grn_insert_id

  ## :nodoc:
  # Association
  belongs_to :item, :polymorphic => true

  class << self
    cattr_accessor :target_models

    ##
    # 全文検索で絞り込む。
    #
    # ==== phrase
    # 検索する単語。スペース区切りで複数指定。
    #
    # ==== options
    # ===== target
    # 検索対象にするモデル、またはそのインスタンスを指定する。
    #
    def match(phrase, options={})
      options = options.symbolize_keys
      if phrase.is_a? String
        phrase = phrase.split(/[\s　]/)
      end

      # モデルで絞り込む
      model_keywords = []
      if options[:model]
        Array.wrap(options.delete(:model)).each do |t|
          if t.is_a?(Class) && t.ancestors.include?(::FulltextSearchable::ActiveRecord::Behaviors::InstanceMethods)
            model_keywords.push(FulltextSearchable.to_model_keyword(t))
          end
        end
      end
      # レコードで絞り込む
      item_keywords = []
      if options[:with]
        Array.wrap(options.delete(:with)).each do |t|
          if t.class.ancestors.include?(::FulltextSearchable::ActiveRecord::Behaviors::InstanceMethods)
            item_keywords.push(FulltextSearchable.to_item_keyword(t))
          end
        end
      end
      [model_keywords, item_keywords].each do |keywords|
        case keywords.count
        when 0
        when 1
          phrase.unshift(keywords.first)
        else
          phrase.unshift("(#{keywords.join(' ')})")
        end
      end
      phrase.map!{|i| '+' + i }

      where("MATCH(`text`) AGAINST(? IN BOOLEAN MODE)",phrase.join(' ')).
        order('`_score` DESC')
    end

    ##
    # 結果を取得し、インデックス元モデルの配列に変換。
    #
    def items(*args)
      select('`_id`, `item_type`, `item_id`').
        includes(:item).all(*args).map{|i| i.item }
    end

    def update(item)
      self.match(FulltextSearchable.to_item_keyword(item)).includes(:item).all.each do |record|
        next unless record.item
        record.text = record.item.fulltext_keywords
        record.save
      end
    end
    ##
    # 全文検索インデックスを再構築する。
    #
    def rebuild_all
      delete_all

      ActiveRecord::Base.descendants.each do |model|
        next unless model.ancestors.include?(::FulltextSearchable::ActiveRecord::Behaviors::InstanceMethods)
        model.all.each do |r|
          create :key => create_key(r), :text => r.fulltext_keywords, :item => r
        end
      end
    end
    ##
    # key用文字列を生成する。
    #
    def create_key(item)
      "#{item.class.name}_#{item.id}"
    end
  end

  protected
  ##
  # 互換のためレコード作成時に主キーをセット。
  #
  def set_grn_insert_id
    self.id = connection.execute('SELECT last_insert_grn_id();').to_a.first.first
  end
end
