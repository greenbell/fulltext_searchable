# coding: utf-8
require 'spec_helper'

describe FulltextIndex do
=begin
  fixtures :news, :blogs, :users
  before(:all) do
    News.delete_all
    Blog.delete_all
    User.delete_all
    News.create :title=>'貸借対照表', :body=>'営業年度の終了時、決算において資産、負債、資本がどれだけあるかを一定のルールにのっとって財務状態を表にしたもの'
    News.create :title=>'損益計算書', :body=>'営業年度中の売り上げと経費、それを差し引いた利益（損失）を記載して表にしたもの'
    News.create :title=>'営業報告書', :body=>'会社の営業の概況、会社の状態を報告したもの'
    News.create :title=>'利益処分案', :body=>'営業年度で得た利益をどのように処分したかを記載するもの'

    User.create :name=>'ユーザ1'
    User.create :name=>'ユーザ2'
    User.create :name=>'ユーザ3'

    Blog.create :title=>'今日は', :body=>'<DIV><FONT size="2">&nbsp;</FONT>曇り時々晴れです。</DIV>', :user_id=>1
    Blog.create :title=>'明日は', :body=>'<DIV><FONT size="2">&nbsp;</FONT>雨のち曇りです。</DIV>', :user_id=>1
    Blog.create :title=>'明後日は', :body=>'<DIV><FONT size="2">&nbsp;</FONT>雪です。</DIV>', :user_id=>2
    FulltextIndex.rebuild_all
  end
  after(:all) do
    News.delete_all
    Blog.delete_all
    User.delete_all
    FulltextIndex.delete_all
  end
=end
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
