class User < ActiveRecord::Base
  fulltext_searchable :name, :blogs => [:title, {:html => :body}]

  has_many :blogs
end
