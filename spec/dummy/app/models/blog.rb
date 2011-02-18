class Blog < ActiveRecord::Base
  fulltext_searchable [:title, :body => :html, :user => [:name]], :referenced => :title

  belongs_to :user
  has_many :comments
  has_many :replies
end
