# coding: utf-8
require 'spec_helper'

describe News do
  it "should be valid" do
    News.superclass.should == ActiveRecord::Base
  end

  it "should not be checkd with changes" do
    @news = News.new
    @news.should_not_receive(:check_fulltext_changes)
    @news.save
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

    it "should not create fulltext index when soft-deleted initially" do
      FulltextIndex.match('例 ダミー').items.should == []
      @news = News.create! :title => '例', :body => 'ダミー'
      @news.destroy
      @news.fulltext_index.text.should == ''
    end
  end

  context "retrieval" do
    before do
      @news = Factory.create(:taisyaku)
      Factory.create(:soneki)
    end
    it "should return item" do
      FulltextIndex.match('決算').items.should == [@news]
    end
    it "should be fulltext-searched with model restriction" do
      Factory.create(:day_after_tomorrow)
      FulltextIndex.match('決算').items.count.should == 2
      FulltextIndex.match('決算', :model => News).items.should == [@news]
      News.fulltext_match('決算').items.should == [@news]
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
    describe "with paranoid removal" do
      it "should nulify fulltext index" do
        @news.destroy
        @news.destroyed?.should be_true
        @news.frozen?.should be_false
        @news.reload.deleted_at.should_not be_nil
        @news.fulltext_index.should_not be_nil
        @news.fulltext_index.text.should == ''
        FulltextIndex.match('営業年度').items.should == []
      end
    end
    describe "with real removal" do
      it "should destroy fulltext index" do
        @fulltext_index = @news.fulltext_index
        @news.destroy!
        @news.destroyed?.should be_true
        FulltextIndex.find_by__id(@fulltext_index.id).should be_nil
        FulltextIndex.match('営業年度').items.should == []
      end
    end
  end

  context "recovery" do
    before do
      @news = Factory.create(:taisyaku)
      @news.destroy
    end
    it "should rebuild fulltext index" do
      @news.fulltext_index.text.should == ''
      @news.recover
      @news.deleted_at.should be_nil
      @news.fulltext_index.reload.text.should ==
        "#{FulltextSearchable.to_model_keyword(News)} #{FulltextSearchable.to_item_keyword(@news)} 貸借対照表 営業年度の終了時、決算において資産、負債、資本がどれだけあるかを一定のルールにのっとって財務状態を表にしたもの"
    end
  end
end

