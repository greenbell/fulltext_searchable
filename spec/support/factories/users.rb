# coding: utf-8

FactoryGirl.define do
  factory :taro, :class => User do
    name '太郎'
    blogs {[ FactoryGirl.create(:today), FactoryGirl.create(:tomorrow) ]}
  end

  factory :jiro, :class => User do
    name '次郎'
    blogs {[ FactoryGirl.create(:day_after_tomorrow) ]}
  end

  factory :hanako, :class => User do
    name '花子'
  end

  factory :john, :class => User do
    name 'john'
    blogs {[ FactoryGirl.create(:yesterday) ]}
  end

  factory :user do
    name 'test'
    blogs {(1..10).map{ FactoryGirl.create(:blog) } }
  end
end
