# coding: utf-8

require 'rails_helper'

describe PaymentsController, type: :controller do
  shared_context '収支情報を登録する' do |params|
    before(:all) do
      @res = client.post('/api/payments', params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  describe '正常系' do
    base_payment = PaymentHelper.test_payment[:income]

    [
      ['カテゴリリソースが既に存在している場合', base_payment],
      ['カテゴリリソースが存在しない場合', base_payment.merge(category: 'not_exist')],
      [
        '複数のカテゴリを指定した場合',
        base_payment.merge(category: 'algieba,other_category'),
      ],
    ].each do |description, payment|
      context description do
        after(:all) { Payment.where(payment.except(:id, :category)).destroy_all }
        include_context '収支情報を登録する', payments: payment
        it_behaves_like 'ステータスコードが正しいこと', '201'
        it_behaves_like '収支情報リソースのキーが正しいこと'
        it_behaves_like 'カテゴリリソースのキーが正しいこと'
        it_behaves_like '収支情報リソースの属性値が正しいこと',
                        payment.except(:id, :category)
        it_behaves_like 'カテゴリリソースの属性値が正しいこと',
                        [payment[:category].split(',').sort]
      end
    end
  end

  describe '異常系' do
    payment_params = PaymentHelper.payment_params.map(&:to_sym)
    test_cases = [].tap do |tests|
      (payment_params.size - 1).times do |i|
        tests << payment_params.combination(i + 1).to_a
      end
    end.flatten(1)

    test_cases.each do |deleted_keys|
      context "#{deleted_keys.join(',')}がない場合" do
        selected_keys = payment_params - deleted_keys
        income = PaymentHelper.test_payment[:income].slice(*selected_keys)
        error_codes = deleted_keys.map {|key| "absent_param_#{key}" }
        include_context '収支情報を登録する', payments: income
        it_behaves_like '400エラーをチェックする', error_codes
      end
    end

    [nil, {}, {payments: nil}, {payments: {}}].each do |params|
      context 'payments パラメーターがない場合' do
        include_context '収支情報を登録する', params
        it_behaves_like '400エラーをチェックする', ['absent_param_payments']
      end
    end

    [
      {payment_type: 'invalid_type'},
      {date: 'invalid_date'},
      {price: 'invalid_price'},
      {payment_type: 'invalid_type', date: 'invalid_date', price: 'invalid_price'},
    ].each do |invalid_param|
      context "#{invalid_param.keys.join(',')}が不正な場合" do
        expense = PaymentHelper.test_payment[:expense].merge(invalid_param)
        error_codes = invalid_param.keys.map {|key| "invalid_param_#{key}" }
        include_context '収支情報を登録する', payments: expense
        it_behaves_like '400エラーをチェックする', error_codes
      end
    end
  end
end
