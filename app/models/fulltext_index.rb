# coding: utf-8

require 'digest/md5'

class FulltextIndex < ActiveRecord::Base
  set_primary_key :_id
  after_create :set_grn_insert_id

  ## :nodoc:
  # Association
  belongs_to :item, :polymorphic => true

  class << self
    cattr_accessor :target_models

    def match(phrase, options={})
      options = options.symbolize_keys
      if phrase.is_a? String
        phrase = phrase.split(' ')
      end
      phrase.map!{|i| '+' + i }
      if options[:target]
        target = Array.wrap(options.delete(:target)).map{|i| i.to_s}
        target.each do |i|
          if target.include?(i)
            phrase.unshift('+' + FulltextSearchable.to_model_keyword(i))
          end
        end
      end
      includes(:item).
        where("MATCH(`text`) AGAINST(? IN BOOLEAN MODE)",phrase.join(' ')).
        order('`_score` DESC').
        all.map{|i| i.item }
    end
  end

  def set_grn_insert_id
    self.id = connection.execute('SELECT last_insert_grn_id();').to_a.first.first
  end
end
