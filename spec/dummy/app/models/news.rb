class News < ActiveRecord::Base
  fulltext_searchable :title, :body
  acts_as_paranoid
end
