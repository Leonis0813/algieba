# coding: utf-8
require 'rails_helper'

describe PaymentsController, :type => :controller do
  shared_context '家計簿を登録する' do |params, app_auth_header = CommonHelper.app_auth_header|
    before(:all) do
      client.header('Authorization', app_auth_header)
      @res = client.post('/payments.json', params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: クライアントアプリを作成する'

  describe '正常系' do
    after(:all) { Payment.where(test_payment[:income].except(:id)).delete_all }
    include_context '家計簿を登録する', {:payments => PaymentHelper.test_payment[:income]}

    it_behaves_like 'ステータスコードが正しいこと', '201'

    it 'レスポンスの属性値が正しいこと' do
      actual_payment = @pbody.slice(*payment_params).symbolize_keys
      expected_payment = test_payment[:income].except(:id)
      expect(actual_payment).to eq expected_payment
    end
  end

  describe '異常系' do
    context 'Authorizationヘッダーがない場合' do
      include_context '家計簿を登録する', {:payments => PaymentHelper.test_payment[:income]}, nil
      it_behaves_like '400エラーをチェックする', ['absent_header']
    end

    payment_params = PaymentHelper.payment_params.map(&:to_sym)
    test_cases = [].tap do |tests|
      (payment_params.size - 1).times {|i| tests << payment_params.combination(i + 1).to_a }
    end.flatten(1)

    test_cases.each do |deleted_keys|
      context "#{deleted_keys.join(',')}がない場合" do
        selected_keys = payment_params - deleted_keys
        include_context '家計簿を登録する', {:payments => PaymentHelper.test_payment[:income].slice(*selected_keys)}
        it_behaves_like '400エラーをチェックする', deleted_keys.map {|key| "absent_param_#{key}" }
      end
    end

    [nil, {}, {:payments => nil}, {:payments => {}}].each do |params|
      context 'payments パラメーターがない場合' do
        include_context '家計簿を登録する', params
        it_behaves_like '400エラーをチェックする', ['absent_param_payments']
      end
    end

    [
      {:payment_type => 'invalid_type'},
      {:date => 'invalid_date'},
      {:price => 'invalid_price'},
      {:payment_type => 'invalid_type', :date => 'invalid_date', :price => 'invalid_price'},
    ].each do |invalid_param|
      context "#{invalid_param.keys.join(',')}が不正な場合" do
        include_context '家計簿を登録する', {:payments => PaymentHelper.test_payment[:expense].merge(invalid_param)}
        it_behaves_like '400エラーをチェックする', invalid_param.keys.map {|key| "invalid_param_#{key}" }
      end
    end
  end
end
