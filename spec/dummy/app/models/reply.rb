class Reply < ActiveRecord::Base
  self.table_name = 'comments'
  belongs_to :blog
end
