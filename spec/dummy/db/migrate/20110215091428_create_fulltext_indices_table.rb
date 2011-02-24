class CreateFulltextIndicesTable < ActiveRecord::Migration
  def self.up
    create_fulltext_index_table
  end

  def self.down
    drop_table :fulltext_indices
  end
end
