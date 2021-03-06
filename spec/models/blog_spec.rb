# coding: utf-8
require 'spec_helper'

describe Blog do
  it "should be valid" do
    Blog.superclass.should == ActiveRecord::Base
  end

  it "should be checkd with changes" do
    @blog = Blog.new
    @blog.should_receive(:check_fulltext_changes)
    @blog.save
  end

  context "creation" do
    it "should create fulltext index" do
      FulltextIndex.match('お知らせ').items.should == []
      @blog = Blog.new :title => '題名', :body => '<h1>お知らせ</h1>', :user => FactoryGirl.create(:hanako)
      @blog.save
      @blog.fulltext_index.text.should ==
        "#{FulltextSearchable.to_model_keyword(Blog)} #{FulltextSearchable.to_item_keyword(@blog)} 題名 お知らせ #{FulltextSearchable.to_item_keyword(@blog.user)} 花子"
      FulltextIndex.match('お知らせ').items.should == [@blog]
    end

    it "should create fulltext index with deep nested models" do
      @user = FactoryGirl.create(:john)
      @user.fulltext_index.text.should == '7d3ecc6a9 7d3ecc6a_1 john 392955b1_1 昨日の天気は a69403a7_1 超寒い！！！１１<> 0e4e4340_1 1'
    end
  end

  context "retrieval" do
    before do
      @blog = FactoryGirl.create(:today)
    end

    it "should return item" do
      FulltextIndex.match('晴れ').items.should == [@blog]
    end
  end

  context "updating" do
    before do
      @blog = FactoryGirl.create(:taro).blogs.first
    end

    it "should update fulltext index" do
      FulltextIndex.match('晴れ 雨').items.should == []
      @blog.body = '<DIV><FONT size="2">&nbsp;</FONT>曇り時々晴れでところにより一時にわか雨です。</DIV>'
      @blog.save
      @blog.fulltext_index.text.should ==
        "#{FulltextSearchable.to_model_keyword(Blog)} #{FulltextSearchable.to_item_keyword(@blog)} 今日の天気は  曇り時々晴れでところにより一時にわか雨です。 #{FulltextSearchable.to_item_keyword(@blog.user)} 太郎"
      FulltextIndex.match('晴れ 雨').items.should == [@blog]
    end

    it "should work with malformed html" do
      FulltextIndex.match('晴れ 雨').items.should == []
      @blog.body = '<DIV><FONT size="2">&nbsp;曇り<a name="abc">時々晴れで<b>ところにより</FONT>一時超にわか雨</b>です。</DIV>'
      @blog.save
      @blog.fulltext_index.text.should ==
        "#{FulltextSearchable.to_model_keyword(Blog)} #{FulltextSearchable.to_item_keyword(@blog)} 今日の天気は  曇り時々晴れでところにより一時超にわか雨です。 #{FulltextSearchable.to_item_keyword(@blog.user)} 太郎"
      FulltextIndex.match('晴れ 雨').items.should == [@blog]
    end

    it "should also update fulltext index with update of associated model" do
      @blog.user.update_attributes :name => '東京太郎'
      @blog.reload
      @blog.fulltext_index.text.should ==
        "#{FulltextSearchable.to_model_keyword(Blog)} #{FulltextSearchable.to_item_keyword(@blog)} 今日の天気は  曇り時々晴れです。 #{FulltextSearchable.to_item_keyword(@blog.user)} 東京太郎"
      FulltextIndex.match('晴れ 東京').items.should == [@blog]
    end
  end

  context "deletion" do
    before do
      @blog = FactoryGirl.create(:today)
    end

    it "should destroy fulltext index" do
      @blog.destroy
      lambda do
        @blog.fulltext_index.reload or raise ActiveRecord::RecordNotFound
      end.should raise_error ActiveRecord::RecordNotFound
      FulltextIndex.match('今日').items.should == []
    end

    it "should not care fulltext index if not exists" do
      FulltextIndex.delete_all
      lambda{ @blog.destroy }.should_not raise_error
    end
  end

  context "update optimization" do
    before do
      @user = FactoryGirl.create(:taro)
      @blog = @user.blogs.first
    end

    it "should update related models with change of referenced attribute" do
      @blog.title = @blog.title + 'foo'
      FulltextIndex.should_receive(:update).with(@blog)
      @blog.save
    end

    it "should not update related models with change of non-referenced attribute" do
      @blog.body = @blog.body + 'foo'
      FulltextIndex.should_not_receive(:update)
      @blog.save
      @blog.fulltext_index.reload.text.should ==
        '392955b1b 392955b1_1 今日の天気は  曇り時々晴れです。foo 7d3ecc6a_1 太郎'
    end
  end
end
