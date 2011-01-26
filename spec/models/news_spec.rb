# coding: utf-8
require 'spec_helper'

describe News do
  it "should be valid" do
    News.superclass.should == ActiveRecord::Base
  end

  context "creation" do
    it "should create fulltext index" do
      FulltextIndex.match('例 ダミー').items.should == []
      @news = News.new :title => '例', :body => 'ダミー'
      @news.save
      @news.fulltext_index.text.should ==
        "#{FulltextSearchable.to_model_keyword(News)} #{FulltextSearchable.to_item_keyword(@news)} 例 ダミー"
      FulltextIndex.match('例 ダミー').items.should == [@news]
    end
  end

  context "retrieval" do
    before do
      @news = Factory.create(:taisyaku)
    end
    it "should return item" do
      FulltextIndex.match('営業年度').items.should == [@news]
    end
  end

  context "updating" do
    before do
      @news = Factory.create(:taisyaku)
    end
    it "should update fulltext index" do
      FulltextIndex.match('営業年度 楽しい').items.should == []
      @news.body = "営業年度の終了時、決算において資産、負債、資本がどれだけあるかを一定のルールにのっとって財務状態を表にした楽しいもの"
      @news.save
      @news.fulltext_index.reload.text.should ==
        "#{FulltextSearchable.to_model_keyword(News)} #{FulltextSearchable.to_item_keyword(@news)} 貸借対照表 営業年度の終了時、決算において資産、負債、資本がどれだけあるかを一定のルールにのっとって財務状態を表にした楽しいもの"
      FulltextIndex.match('営業年度 楽しい').items.should == [@news]
    end
  end

  context "deletion" do
    before do
      @news = Factory.create(:taisyaku)
    end
    it "should destroy fulltext index" do
      @news.destroy
      @news.fulltext_index.reload.should be_nil
      FulltextIndex.match('営業年度').items.should == []
    end
  end
end
