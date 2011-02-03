class Comment < ActiveRecord::Base
  belongs_to :blog
  fulltext_searchable do
    'text from proc'
  end
end
