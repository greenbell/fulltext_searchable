class Comment < ActiveRecord::Base
  belongs_to :blog
  fulltext_searchable :body
end
