# coding: utf-8
$:.unshift(File.dirname(__FILE__))

require 'active_record/base'
require 'digest/md5'
##
# == 概要
# モデルを全文検索対応にするプラグイン
#
module FulltextSearchable
  require 'fulltext_searchable/engine' if defined?(Rails)

  PROCESS_UNIT = 1000

  class << self
    def to_model_keyword(model)
      '' + Digest::MD5.hexdigest('FulltextSearchable_'+model.to_s)[0,9] + ''
    end
    def to_item_keyword(item)
      '' + Digest::MD5.hexdigest('FulltextSearchable_'+item.class.to_s)[0,8] + '_' + item.id.to_s + ''
    end
  end

  autoload :ActiveRecord, 'fulltext_searchable/active_record'
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.class_eval { include FulltextSearchable::ActiveRecord }
end

