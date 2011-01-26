ActiveRecord::Schema.define(:version => 0) do

    execute( <<SQL
      CREATE TABLE fulltext_indices (
        `_id` INT(11),
        `key` VARCHAR(32),
        `item_type` VARCHAR(255),
        `item_id` INT(11),
        `text` TEXT,
        `_score` FLOAT,
        PRIMARY KEY(`key`),
        FULLTEXT INDEX (`text`) WITH PARSER mecab
      ) ENGINE = groonga COLLATE utf8_unicode_ci;
SQL
    )

end
