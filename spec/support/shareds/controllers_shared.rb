# coding: utf-8

shared_context '収支情報を登録する' do |payments = PaymentHelper.test_payment.values|
  include_context 'トランザクション作成'

  before(:all) do
    payments.each do |payment|
      category_names = payment[:categories]
      categories = category_names.map {|name| Category.find_or_create_by(name: name) }
      payment = Payment.new(payment.except(:categories))
      payment.categories = categories
      payment.save!
    end
  end
end
