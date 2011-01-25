# coding: utf-8

Factory.define :taisyaku, :class => News do |f|
  f.title '貸借対照表'
  f.body  '営業年度の終了時、決算において資産、負債、資本がどれだけあるかを一定のルールにのっとって財務状態を表にしたもの'
end

Factory.define :soneki, :class => News do |f|
  f.title '損益計算書'
  f.body  '営業年度中の売り上げと経費、それを差し引いた利益（損失）を記載して表にしたもの'
end

Factory.define :eigyo, :class => News do |f|
  f.title '営業報告書'
  f.body  '会社の営業の概況、会社の状態を報告したもの'
end

Factory.define :rieki, :class => News do |f|
  f.title '利益処分案'
  f.body  '営業年度で得た利益をどのように処分したかを記載するもの'
end

