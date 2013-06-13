# coding: utf-8

FactoryGirl.define do
  factory :today, :class => Blog do
    title '今日の天気は'
    body  '<DIV><FONT size="2">&nbsp;</FONT>曇り時々晴れです。</DIV>'
  end

  factory :tomorrow, :class => Blog do
    title '明日の天気は'
    body  '<DIV><FONT size="2">&nbsp;</FONT>雨のち曇りです。</DIV>'
  end

  factory :day_after_tomorrow, :class => Blog do
    title '明後日の天気は'
    body  '<DIV><FONT size="2">決算の&nbsp;</FONT>雪です。</DIV>'
  end

  factory :yesterday, :class => Blog do
    title '昨日の天気は'
    body  '<marquee>雹でした</marquee>'
    comments {[ FactoryGirl.create(:comment) ]}
  end

  factory :blog do
    title Faker::Lorem.sentence[1..20]
    body  Faker::Lorem.paragraph
  end
end
