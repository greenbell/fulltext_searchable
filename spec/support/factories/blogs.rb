# coding: utf-8

Factory.define :today, :class => Blog do |f|
  f.title '今日の天気は'
  f.body  '<DIV><FONT size="2">&nbsp;</FONT>曇り時々晴れです。</DIV>'
end

Factory.define :tomorrow, :class => Blog do |f|
  f.title '明日の天気は'
  f.body  '<DIV><FONT size="2">&nbsp;</FONT>雨のち曇りです。</DIV>'
end

Factory.define :day_after_tomorrow, :class => Blog do |f|
  f.title '明後日の天気は'
  f.body  '<DIV><FONT size="2">決算の&nbsp;</FONT>雪です。</DIV>'
end

Factory.define :yesterday, :class => Blog do |f|
  f.title '昨日の天気は'
  f.body  '<marquee>雹でした</marquee>'
  f.comments {[ Factory(:comment) ]}
end


Factory.define :blog do |f|
  f.title Faker::Lorem.sentence[1..20]
  f.body  Faker::Lorem.paragraph
end
