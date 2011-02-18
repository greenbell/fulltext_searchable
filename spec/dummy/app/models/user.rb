class User < ActiveRecord::Base
  fulltext_searchable [:name, :blogs =>[ :title, :comments => { :body => :html }, :replies => :blog_id ]]

  has_many :blogs
end
