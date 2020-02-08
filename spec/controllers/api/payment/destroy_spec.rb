# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  shared_context '収支情報を削除する' do |payment_id|
    before(:all) do
      payment_id ||= @payment_id
      res = client.delete("/api/payments/#{payment_id}")
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  include_context '収支情報を登録する'

  describe '正常系' do
    before(:all) { @payment_id = Payment.first.payment_id }
    include_context '収支情報を削除する'
    it_behaves_like 'レスポンスが正しいこと', status: 204, body: ''
  end

  describe '異常系' do
    context '存在しないidを指定した場合' do
      include_context '収支情報を削除する', 'not_exist'
      it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
    end
  end
end
