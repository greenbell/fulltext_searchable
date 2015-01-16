# coding: utf-8
require 'spec_helper'

describe FulltextIndex do
  it "should be valid" do
    FulltextIndex.superclass.should == ActiveRecord::Base
  end

  context "rebuilding" do
    before do
      @taisyaku = FactoryGirl.create(:taisyaku)
      News.delete_all! @taisyaku.id
      @soneki = FactoryGirl.create(:soneki)
      News.where('id = ?',@soneki.id).update_all("body = '夕飯はカレーです。'")
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
      FactoryGirl.create(:taisyaku)
      FactoryGirl.create(:soneki)
      FactoryGirl.create(:eigyo)
      FactoryGirl.create(:rieki)
      @taro   = FactoryGirl.create(:taro)
      @jiro   = FactoryGirl.create(:jiro)
      @hanako = FactoryGirl.create(:hanako, :name => 'hanako')
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
      FulltextIndex.match('太郎', :model => News).items.count.should == 0
      FulltextIndex.match('太郎', :model => [Blog, News]).items.count.should == 2
      FulltextIndex.match('太郎', :model => [Blog, News, User]).items.count.should == 3
    end

    it "should fulltext searchable with target item specified" do
      FulltextIndex.match('天気').items.count.should == 5
      FulltextIndex.match('天気', :with => @taro).items.count.should == 3
    end

    it "should fulltext searchable with target items and models specified" do
      FulltextIndex.match('天気').items.count.should == 5
      FulltextIndex.match('天気', :with => @jiro, :model => Blog).items.count.should == 1
      FulltextIndex.match('天気', :with => @jiro, :model => [Blog, User]).items.count.should == 2
      FulltextIndex.match('天気', :with => [@taro, @jiro], :model => Blog).items.count.should == 3
      FulltextIndex.match('天気', :with => [@taro, @jiro], :model => [Blog, User]).items.count.should == 5
    end

    it "should not break with ActiveRecord's eager loading behavior" do
      expect{ FulltextIndex.match('ab.').items }.not_to raise_error
    end

    it "should not contain nil in items" do
      Blog.delete_all :id => @jiro.blogs.map(&:id)
      FulltextIndex.match('天気').items.should_not include(nil)
    end

    it "should not break when keywords with redundant speces are passed" do
      FulltextIndex.match(' 営業 状態').items.count.should == 2
      FulltextIndex.match('営業  状態').items.count.should == 2
      FulltextIndex.match("　営業\t状態 ").items.count.should == 2
    end

    it "should ignore special characters and not break when meta characters are passed" do
      "+-><()~*\"".split(//).each do |character|
        FulltextIndex.match(character + '太郎', :model => User).items.count.should == 1
      end
      FulltextIndex.match('++太郎', :model => User).items.count.should == 1
      FulltextIndex.match(['+太郎'], :model => User).items.count.should == 1
    end

    it "should fulltext searchable with one character of alphabet" do
      FulltextIndex.match('h').items.count.should == 1
      FulltextIndex.match('h', :model => User).items.count.should == 1
      FulltextIndex.match('h', :model => User, :with => @hanako).items.count.should == 1
    end
  end

  context "optimization" do
    before do
      @taro = FactoryGirl.create(:taro)
      @jiro = FactoryGirl.create(:jiro)
      FactoryGirl.create(:taisyaku)
    end
    it "should utilize groonga_fast_order_limit optization" do
      fast = get_mroonga_status_var('fast_order_limit')
      FulltextIndex.match('天気').limit(1).all.to_a
      (get_mroonga_status_var('fast_order_limit') - fast).should == 1
    end

    it "should utilize groonga_count_skip optization" do
      skip = get_mroonga_status_var('count_skip')
      FulltextIndex.match('天気').count
      (get_mroonga_status_var('count_skip') - skip).should == 1
    end

    it "should utilize both of optization with pagination" do
      fast = get_mroonga_status_var('fast_order_limit')
      skip = get_mroonga_status_var('count_skip')
      FulltextIndex.match('天気').paginate(:per_page=>1, :page=>3).to_a
      (get_mroonga_status_var('fast_order_limit') - fast).should == 1
      (get_mroonga_status_var('count_skip') - skip).should == 1
    end

    def get_mroonga_status_var(name)
      ActiveRecord::Base.connection.
        execute("SHOW STATUS LIKE '#{ActiveRecord::Base.connection.mroonga_storage_engine_name}_#{name}';").first.last.to_i
    end
  end
end
