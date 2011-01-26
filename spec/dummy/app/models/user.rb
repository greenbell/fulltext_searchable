class User < ActiveRecord::Base
  fulltext_searchable :name, :blogs => :title

  has_many :blogs
end
