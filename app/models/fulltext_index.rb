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
    # 検索対象にするモデルを指定する。
    #
    def match(phrase, options={})
      options = options.symbolize_keys
      if phrase.is_a? String
        phrase = phrase.split(/[\s　]/)
      end
      phrase.map!{|i| '+' + i }
      if options[:target]
        Array.wrap(options.delete(:target)).each do |i|
          phrase.unshift('+' + FulltextSearchable.to_model_keyword(i.to_s))
        end
      end
      where("MATCH(`text`) AGAINST(? IN BOOLEAN MODE)",phrase.join(' ')).
        order('`_score` DESC')
    end

    ##
    # 結果を取得し、インデックス元モデルの配列に変換。
    #
    def items(*args)
      includes(:item).all(*args).map{|i| i.item }
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
