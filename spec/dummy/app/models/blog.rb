class Blog < ActiveRecord::Base
  fulltext_searchable :title, :body => :html, :user => [:name]

  belongs_to :user
end
