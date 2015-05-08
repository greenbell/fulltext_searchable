# coding: utf-8

require 'digest/md5'

##
# == 概要
# 全文検索インデックスとして機能するモデル。
#
class FulltextIndex < ActiveRecord::Base
  BOOLEAN_META_CHARACTER_REGEXP = /^[\+\-><\(\)~*"]*/
  self.table_name = FulltextSearchable::TABLE_NAME
  self.primary_key = :_id
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
    # ===== model
    # 検索対象にするモデルを指定。
    # 例: FulltextIndex.match('天気', :model => User)
    # ===== with
    # 検索対象にしたいレコード(AR object)を指定する。
    # 例: FulltextIndex.match('天気', :with => @user)
    #
    def match(phrase, options={})
      options = options.symbolize_keys
      phrase = phrase.split(/[\s　]/) if phrase.is_a? String
      phrase.map!{|word| word.gsub(BOOLEAN_META_CHARACTER_REGEXP, '')}
      phrase.reject!(&:blank?)
      # escape special character
      phrase.map! do |word|
        '"' + word.gsub(/[\\"]/) { |c| "\\#{c}" } + '"'
      end

      # モデルで絞り込む
      model_keywords = []
      if options[:model]
        Array.wrap(options.delete(:model)).each do |t|
          if t.is_a?(Class) && indexed?(t)
            model_keywords.push(FulltextSearchable.to_model_keyword(t))
          end
        end
      end
      # レコードで絞り込む
      item_keywords = []
      if options[:with]
        Array.wrap(options.delete(:with)).each do |t|
          if indexed?(t.class)
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

      if connection.mroonga_match_against?
        where("MATCH(`text`) AGAINST(? IN BOOLEAN MODE)",phrase.join(' ')).
          order(sanitize_sql_array(["MATCH(`text`) AGAINST(? IN BOOLEAN MODE)",phrase.join(' ')]))
      else
        where("MATCH(`text`) AGAINST(? IN BOOLEAN MODE)",phrase.join(' ')).
          order('`_score` DESC')
      end
    end

    ##
    # 結果を取得し、インデックス元モデルの配列に変換。
    #
    def items(*args)
      select('`_id`, `item_type`, `item_id`').
        preload(:item).all(*args).map{|i| i.item }.compact
    end
    ##
    # 特定レコードの更新をインデックスに反映する。
    #
    def update(item)
      match(FulltextSearchable.to_item_keyword(item)).
        includes(:item).all.each do |record|
        next unless record.item
        record.text = record.item.fulltext_keywords
        record.save!
      end
    end
    ##
    # 全文検索インデックスを再構築する。
    #
    def rebuild_all
      if connection.tables.include?(FulltextSearchable::TABLE_NAME)
        connection.drop_table FulltextSearchable::TABLE_NAME
      end
      connection.create_fulltext_index_table

      ActiveRecord::Base.descendants.each do |model|
        next unless model.table_exists? &&
          model.fulltext_searchable?
        n = 0
        depends = model.fulltext_dependent_models
        begin
          rows = model.unscoped.includes(depends).offset(n).
            limit(FulltextSearchable::PROCESS_UNIT).order(:id).all
          rows.each do |r|
            index = where(:key => create_key(r)).first || new(:key => create_key(r))
            index.update_attributes :text => r.fulltext_keywords, :item => r
          end
          n += rows.count
        end while rows.count >= FulltextSearchable::PROCESS_UNIT
      end
    end
    ##
    # key用文字列を生成する。
    #
    def create_key(item)
      "#{item.class.name}_#{'% 10d' % item.id}"
    end

    protected

    ##
    # 全文検索対応モデルかどうかを判定し、返す。
    #
    def indexed?(klass)
      klass.respond_to?(:fulltext_searchable?) && klass.fulltext_searchable?
    end
  end

  protected
  ##
  # 互換のためレコード作成時に主キーをセット。
  #
  def set_grn_insert_id
    self.id = self.class.connection.execute('SELECT last_insert_grn_id();').to_a.first.first
  end
end
