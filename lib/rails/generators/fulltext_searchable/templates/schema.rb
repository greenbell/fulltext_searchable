ActiveRecord::Schema.define(:version => 0) do

    execute( <<SQL
      CREATE TABLE fulltexts (
        _id INT(11),
        resource_type VARCHAR(255),
        resource_id INT(11),
        text TEXT,
        _score FLOAT,
        KEY(`resource_id`),
        FULLTEXT INDEX (`text`) WITH PARSER mecab
      ) ENGINE = groonga DEFAULT CHARSET utf8;
SQL
    )

end
