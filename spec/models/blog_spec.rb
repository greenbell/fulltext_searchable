# coding: utf-8
require 'spec_helper'

describe Blog do
  before do

  end
  it "should be valid" do
    Blog.superclass.should == ActiveRecord::Base
  end

end
