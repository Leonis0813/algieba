# coding: utf-8
require 'rails_helper'

describe PaymentsController, :type => :controller do
  shared_context '家計簿を取得する' do |id, app_auth_header = CommonHelper.app_auth_header|
    before(:all) do
      client.header('Authorization', app_auth_header)
      @res = client.get("/payments/#{id}.json")
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: クライアントアプリを作成する'
  include_context '事前準備: 家計簿を登録する'

  describe '正常系' do
    include_context '家計簿を取得する', PaymentHelper.test_payment[:income][:id]

    it_behaves_like 'ステータスコードが正しいこと', '200'

    it 'レスポンスの属性値が正しいこと' do
      actual_payment = @pbody.slice(*payment_params).symbolize_keys
      expected_payments = test_payment[:income].except(:id)
      expect(actual_payment).to eq expected_payments
    end
  end

  describe '異常系' do
    context 'Authorizationヘッダーがない場合' do
      include_context '家計簿を取得する', PaymentHelper.test_payment[:income][:id], nil
      it_behaves_like '400エラーをチェックする', ['absent_header']
    end

    context '存在しないidを指定した場合' do
      include_context '家計簿を取得する', 100
      it_behaves_like 'ステータスコードが正しいこと', '404'
    end
  end
end
