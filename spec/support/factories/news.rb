# coding: utf-8

FactoryGirl.define do
  factory :taisyaku, :class => News do
    title '貸借対照表'
    body  '営業年度の終了時、決算において資産、負債、資本がどれだけあるかを一定のルールにのっとって財務状態を表にしたもの'
  end

  factory :soneki, :class => News do
    title '損益計算書'
    body  '営業年度中の売り上げと経費、それを差し引いた利益（損失）を記載して表にしたもの'
  end

  factory :eigyo, :class => News do
    title '営業報告書'
    body  '会社の営業の概況、会社の状態を報告したもの'
  end

  factory :rieki, :class => News do
    title '利益処分案'
    body  '営業年度で得た利益をどのように処分したかを記載するもの'
  end
end
