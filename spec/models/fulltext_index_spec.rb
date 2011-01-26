# coding: utf-8
require 'spec_helper'

describe FulltextIndex do
  before do
    Factory.create(:taisyaku)
    Factory.create(:soneki)
    Factory.create(:eigyo)
    Factory.create(:rieki)
  end
  it "should be valid" do
    FulltextIndex.superclass.should == ActiveRecord::Base
  end

  context "retrieval" do
    it "should return 4 records with fulltext matching of '営業'" do
      FulltextIndex.match('営業', :target => News).items.count.should == 4
    end

    it "should return 4 records with fulltext matching of '営業 状態'" do
      FulltextIndex.match('営業 状態', :target => News).items.count.should == 2
    end

    it "should return 4 records with fulltext matching of '営業　状態'(fullwidth-space delimiterd)" do
      FulltextIndex.match('営業　状態', :target => News).items.count.should == 2
    end
  end
end
