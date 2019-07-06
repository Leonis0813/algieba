# coding: utf-8

shared_context '事前準備: 収支情報を登録する' do |payments = PaymentHelper.test_payment.values|
  include_context 'トランザクション作成'
  before(:all) do
    payments.each do |payment|
      category_names = payment[:category].split(',')
      categories = category_names.map {|name| Category.find_or_create_by(name: name) }
      payment = Payment.new(payment.except(:category))
      payment.categories = categories
      payment.save!
    end
  end
end
