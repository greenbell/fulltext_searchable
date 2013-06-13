# coding: utf-8
require 'spec_helper'

describe Comment do
  it "should create fulltext index with proc" do
    @comment = FactoryGirl.create(:comment)
    @comment.fulltext_index.text.should == 'a69403a7e a69403a7_1 text from proc'
  end
end
