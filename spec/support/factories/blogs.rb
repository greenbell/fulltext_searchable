# coding: utf-8

Factory.define :today, :class => Blog do |f|
  f.title '今日は'
  f.body  '<DIV><FONT size="2">&nbsp;</FONT>曇り時々晴れです。</DIV>'
  f.user { Factory(:taro) }
end

Factory.define :tomorrow, :class => Blog do |f|
  f.title '明日は'
  f.body  '<DIV><FONT size="2">&nbsp;</FONT>雨のち曇りです。</DIV>'
  f.user { Factory(:taro) }
end

Factory.define :day_after_tomorrow, :class => Blog do |f|
  f.title '明後日は'
  f.body  '<DIV><FONT size="2">&nbsp;</FONT>雪です。</DIV>'
  f.user { Factory(:jiro) }
end

