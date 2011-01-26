# coding: utf-8
require 'spec_helper'

describe Blog do
  it "should be valid" do
    Blog.superclass.should == ActiveRecord::Base
  end

  context "creation" do
    it "should create fulltext index" do
      FulltextIndex.match('お知らせ').items.should == []
      @blog = Blog.new :title => '題名', :body => '<h1>お知らせ</h1>', :user => Factory.create(:hanako)
      @blog.save
      @blog.fulltext_index.text.should ==
        "#{FulltextSearchable.to_model_keyword(Blog)} #{FulltextSearchable.to_item_keyword(@blog)} 題名 お知らせ #{FulltextSearchable.to_item_keyword(@blog.user)} 花子"
      FulltextIndex.match('お知らせ').items.should == [@blog]
    end
  end

  context "retrieval" do
    before do
      @blog = Factory.create(:today)
    end

    it "should return item" do
      FulltextIndex.match('晴れ').items.should == [@blog]
    end
  end

  context "updating" do
    before do
      @blog = Factory.create(:today)
    end

    it "should update fulltext index" do
      FulltextIndex.match('晴れ 雨').items.should == []
      @blog.body = '<DIV><FONT size="2">&nbsp;</FONT>曇り時々晴れでところにより一時にわか雨です。</DIV>'
      @blog.save
      @blog.fulltext_index.reload.text.should ==
        "#{FulltextSearchable.to_model_keyword(Blog)} #{FulltextSearchable.to_item_keyword(@blog)} 今日は &nbsp;曇り時々晴れでところにより一時にわか雨です。 #{FulltextSearchable.to_item_keyword(@blog.user)} 太郎"
      FulltextIndex.match('晴れ 雨').items.should == [@blog]
    end

    it "should work with malformed html" do
      FulltextIndex.match('晴れ 雨').items.should == []
      @blog.body = '<DIV><FONT size="2">&nbsp;曇り<a name="abc">時々晴れで<b>ところにより</FONT>一時超にわか雨</b>です。</DIV>'
      @blog.save
      @blog.fulltext_index.reload.text.should ==
        "#{FulltextSearchable.to_model_keyword(Blog)} #{FulltextSearchable.to_item_keyword(@blog)} 今日は &nbsp;曇り時々晴れでところにより一時超にわか雨です。 #{FulltextSearchable.to_item_keyword(@blog.user)} 太郎"
      FulltextIndex.match('晴れ 雨').items.should == [@blog]
    end

    it "should also update fulltext index with update of associated model" do
      @blog.user.update_attributes :name => '東京太郎'
      @blog.fulltext_index.reload.text.should ==
        "#{FulltextSearchable.to_model_keyword(Blog)} #{FulltextSearchable.to_item_keyword(@blog)} 今日は &nbsp;曇り時々晴れです。 #{FulltextSearchable.to_item_keyword(@blog.user)} 東京太郎"
      FulltextIndex.match('晴れ 東京').items.should == [@blog]
    end
  end

  context "deletion" do
    before do
      @blog = Factory.create(:today)
    end

    it "should destroy fulltext index" do
      @blog.destroy
      @blog.fulltext_index.reload.should be_nil
      FulltextIndex.match('今日').items.should == []
    end
  end
end
