# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  shared_context '収支情報を取得する' do |id|
    before(:all) do
      res = client.get("/api/payments/#{id}")
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  include_context '事前準備: 収支情報を登録する'

  describe '正常系' do
    payment = PaymentHelper.test_payment[:income]
    response_categories = payment[:categories].map do |category_name|
      {name: category_name, description: nil}
    end
    body = payment.merge(categories: response_categories)
    include_context '収支情報を取得する', payment[:id]
    it_behaves_like '収支リソースのレスポンスが正しいこと', status: 200, body: body
  end

  describe '異常系' do
    context '存在しないidを指定した場合' do
      include_context '収支情報を取得する', 100
      it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
    end
  end
end
