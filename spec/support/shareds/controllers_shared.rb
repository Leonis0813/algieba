# coding: utf-8

shared_context '収支情報を登録する' do |payments = PaymentHelper.test_payment.values|
  include_context 'トランザクション作成'

  before(:all) do
    payments.each do |payment|
      categories = payment[:categories].map {|name| build(:category, name: name) }
      tags = payment[:tags].map {|name| build(:tag, name: name) }
      payment = Payment.new(payment.except(:categories, :tags))
      payment.categories = categories
      payment.tags = tags
      payment.save!
    end
  end
end
