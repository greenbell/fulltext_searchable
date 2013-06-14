# encoding: utf-8

module FulltextSearchable
  module Mysql2Adapter
    def create_fulltext_index_table
      execute( <<SQL
CREATE TABLE IF NOT EXISTS `#{::FulltextSearchable::TABLE_NAME}` (
  `_id` INT(11),
  `key` VARCHAR(32),
  `item_type` VARCHAR(255),
  `item_id` INT(11),
  `text` TEXT,
  #{"`_score` FLOAT," unless mroonga_match_against?}
  PRIMARY KEY(`key`),
  #{"UNIQUE " if mroonga_unique_hash_index_safe?}INDEX(`_id`) USING HASH,
  FULLTEXT INDEX (`text`)
) ENGINE = #{mroonga_storage_engine_name} COLLATE utf8_unicode_ci;
SQL
      )
    end

    def mroonga_match_against?
      mroonga_version >= '1.2'
    end

    def mroonga_version
      execute("SHOW VARIABLES LIKE '#{mroonga_storage_engine_name}_version';").map(&:last).first ||
        '0.0' # older than 1.0
    end

    def mroonga_storage_engine_name
      @mroonga_storage_engine_name ||=
        execute('SHOW ENGINES;').map(&:first).find{|name| name =~ /.+roonga/} or
        raise "mroonga or groonga storage engine is not installed"
    end

    private

    ##
    # mroonga on MacOS X fails truncation/deletion of unique hash indexed table.
    # As a workaround, we actually temporary table with unique hash index and
    # see if it is safe to truncate it.
    #
    def mroonga_unique_hash_index_safe?
      temporary_table_name = ::FulltextSearchable::TABLE_NAME + '_temp_' + Time.now.to_i.to_s
      execute( <<SQL
CREATE TABLE IF NOT EXISTS `#{temporary_table_name}` (
  `_id` INT(11),
  UNIQUE INDEX(`_id`) USING HASH
) ENGINE = #{mroonga_storage_engine_name} COLLATE utf8_unicode_ci;
SQL
      )
      safe = true
      begin
        execute("TRUNCATE TABLE `#{temporary_table_name}`;")
      rescue 
        safe = false
      end
      drop_table temporary_table_name
      safe
    end
  end
end

