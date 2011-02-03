class Reply < ActiveRecord::Base
  set_table_name 'comments'
  belongs_to :blog
end
