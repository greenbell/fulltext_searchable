# coding: utf-8
$:.unshift(File.dirname(__FILE__))

require 'digest/md5'
##
# == 概要
# モデルを全文検索対応にするプラグイン
#
module FulltextSearchable
  require 'fulltext_searchable/engine' if defined?(Rails)

  # 再構築タスク時の一回の処理レコード数
  PROCESS_UNIT = 1000
  TABLE_NAME = 'fulltext_indices'

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

  require 'active_record/connection_adapters/mysql2_adapter'
  ActiveRecord::ConnectionAdapters::Mysql2Adapter.class_eval do
    def create_fulltext_index_table
      execute( <<SQL
CREATE TABLE IF NOT EXISTS `#{::FulltextSearchable::TABLE_NAME}` (
  `_id` INT(11),
  `key` VARCHAR(32),
  `item_type` VARCHAR(255),
  `item_id` INT(11),
  `text` TEXT,
  `_score` FLOAT,
  PRIMARY KEY(`key`),
  UNIQUE INDEX(`_id`) USING HASH,
  FULLTEXT INDEX (`text`)
) ENGINE = groonga COLLATE utf8_unicode_ci;
SQL
      )
    end
  end

  ActiveRecord::SchemaDumper.class_eval do
    def table_with_grn(table, stream)
      if table.to_s == ::FulltextSearchable::TABLE_NAME
        tbl = StringIO.new
        tbl.puts "  create_fulltext_index_table"
        tbl.puts ""
        tbl.rewind
        stream.print tbl.read
      else
        table_without_grn(table, stream)
      end
    end
    alias_method_chain :table, :grn
  end
end
