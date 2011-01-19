class Fulltext < ActiveRecord::Base
  set_primary_key :_id
  after_save :set_grn_insert_id

  def set_grn_insert_id
    if id == 0
      self.id = connection.execute('SELECT last_insert_grn_id();').to_a.first.first
    end
  end
end
