# coding: utf-8

Factory.define :taro, :class => User do |f|
  f.name '太郎'
  f.blogs {[ Factory(:today), Factory(:tomorrow) ]}
end

Factory.define :jiro, :class => User do |f|
  f.name '次郎'
  f.blogs {[ Factory(:day_after_tomorrow) ]}
end

Factory.define :hanako, :class => User do |f|
  f.name '花子'
end

