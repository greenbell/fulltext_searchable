# coding: utf-8
require 'spec_helper'

describe FulltextIndex do
  it "should be valid" do
    FulltextIndex.superclass.should == ActiveRecord::Base
  end

  context "rebuilding" do
    before do
      @taisyaku = Factory.create(:taisyaku)
      @taisyaku.delete
      @soneki = Factory.create(:soneki)
      News.update_all("body = '夕飯はカレーです。'", ['id = ?',@soneki.id])
    end
    it "should update fulltext index" do
      FulltextIndex.all.map{|i| i.text}.should == [
        "1b5f32164 1b5f3216_1 貸借対照表 営業年度の終了時、決算において資産、負債、資本がどれだけあるかを一定のルールにのっとって財務状態を表にしたもの",
        "1b5f32164 1b5f3216_2 損益計算書 営業年度中の売り上げと経費、それを差し引いた利益（損失）を記載して表にしたもの",
      ]
      FulltextIndex.rebuild_all
      FulltextIndex.all.map{|i| i.text}.should == [
        "1b5f32164 1b5f3216_2 損益計算書 夕飯はカレーです。",
      ]
    end
  end

  context "retrieval" do
    before do
      Factory.create(:taisyaku)
      Factory.create(:soneki)
      Factory.create(:eigyo)
      Factory.create(:rieki)
      Factory.create(:taro)
      Factory.create(:jiro)
    end
    it "should fulltext searchable with '営業'" do
      FulltextIndex.match('営業').items.count.should == 4
    end

    it "should fulltext searchable with '営業 状態'" do
      FulltextIndex.match('営業 状態').items.count.should == 2
    end

    it "should fulltext searchable with '営業　状態'(fullwidth-space delimiterd)" do
      FulltextIndex.match('営業　状態').items.count.should == 2
    end

    it "should not match with html tags" do
      FulltextIndex.match('DIV').items.count.should == 0
      FulltextIndex.match('FONT').items.count.should == 0
    end

    it "should fulltext searchable with associated model's keyword" do
      FulltextIndex.match('晴れ 太郎').items.count.should == 1
      FulltextIndex.match('今日 太郎').items.count.should == 2
    end

    it "should fulltext searchable with target model specified" do
      FulltextIndex.match('太郎', :target => News).items.count.should == 0
      FulltextIndex.match('太郎', :target => [Blog, News]).items.count.should == 2
      FulltextIndex.match('太郎', :target => [Blog, News, User]).items.count.should == 3
    end
  end
end
