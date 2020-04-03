# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  shared_context '収支情報を取得する' do |payment_id|
    before(:all) do
      payment_id ||= @payment_id
      res = client.get("/api/payments/#{payment_id}")
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  include_context '収支情報を登録する'

  describe '正常系' do
    payment = PaymentHelper.test_payment[:income]
    before(:all) do
      categories = payment[:categories].map do |category_name|
        Category.find_by(name: category_name).slice(:category_id, :name, :description)
      end
      tags = payment[:tags].map do |tag_name|
        Tag.find_by(name: tag_name).slice(:tag_id, :name)
      end

      @payment_id = Payment.find(payment[:id]).payment_id
      @body = payment.except(:id).merge(
        payment_id: @payment_id,
        categories: categories,
        tags: tags,
      ).deep_stringify_keys
    end
    include_context '収支情報を取得する'
    it_behaves_like 'レスポンスが正しいこと'
  end

  describe '異常系' do
    context '存在しないidを指定した場合' do
      include_context '収支情報を取得する', 'not_exist'
      it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
    end
  end
end
