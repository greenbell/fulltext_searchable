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
      @taro = Factory.create(:taro)
      @jiro = Factory.create(:jiro)
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
    
    it "should perform workaround with ActiveRecord's string-followed-by-period bug" do
      FulltextIndex.match('ab.').items.should_not raise_error ActiveRecord::EagerLoadPolymorphicError
    end
  end

  context "optimization" do
    before do
      @taro = Factory.create(:taro)
      @jiro = Factory.create(:jiro)
      Factory.create(:taisyaku)
    end
    it "should utilize groonga_fast_order_limit optization" do
      fast = get_mysql_status_var('groonga_fast_order_limit')
      FulltextIndex.match('天気').limit(1).all
      (get_mysql_status_var('groonga_fast_order_limit').to_i - fast.to_i).should == 1
    end

    it "should utilize groonga_count_skip optization" do
      skip = get_mysql_status_var('groonga_count_skip')
      FulltextIndex.match('天気').count
      (get_mysql_status_var('groonga_count_skip').to_i - skip.to_i).should == 1
    end

    it "should utilize both of optization with pagination" do
      fast = get_mysql_status_var('groonga_fast_order_limit')
      skip = get_mysql_status_var('groonga_count_skip')
      FulltextIndex.match('天気').paginate(:finder=>:items, :per_page=>1, :page=>3)
      (get_mysql_status_var('groonga_fast_order_limit').to_i - fast.to_i).should == 1
      (get_mysql_status_var('groonga_count_skip').to_i - skip.to_i).should == 1
    end

    def get_mysql_status_var(name)
      ActiveRecord::Base.connection.execute("SHOW STATUS LIKE '#{name}';").first.last.to_i
    end
  end
end
