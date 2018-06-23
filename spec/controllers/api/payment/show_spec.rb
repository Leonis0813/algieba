# coding: utf-8
require 'rails_helper'

describe PaymentsController, :type => :controller do
  shared_context '収支情報を取得する' do |id|
    before(:all) do
      @res = client.get("/api/payments/#{id}")
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: 収支情報を登録する'

  describe '正常系' do
    payment = PaymentHelper.test_payment[:income]
    include_context '収支情報を取得する', payment[:id]
    it_behaves_like 'ステータスコードが正しいこと', '200'
    it_behaves_like '収支情報リソースのキーが正しいこと'
    it_behaves_like 'カテゴリリソースのキーが正しいこと'
    it_behaves_like '収支情報リソースの属性値が正しいこと', payment.except(:id, :category)
    it_behaves_like 'カテゴリリソースの属性値が正しいこと', [payment[:category].split(',').sort]
  end

  describe '異常系' do
    context '存在しないidを指定した場合' do
      include_context '収支情報を取得する', 100
      it_behaves_like 'ステータスコードが正しいこと', '404'
    end
  end
end
