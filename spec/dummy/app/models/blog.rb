class Blog < ActiveRecord::Base
  fulltext_searchable :title, :html => :body, :user => [:name]

  belongs_to :user
end
