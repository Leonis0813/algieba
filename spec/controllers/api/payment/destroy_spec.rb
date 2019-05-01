# coding: utf-8

require 'rails_helper'

describe PaymentsController, type: :controller do
  shared_context '収支情報を削除する' do |id|
    before(:all) do
      @res = client.delete("/api/payments/#{id}")
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: 収支情報を登録する'

  describe '正常系' do
    include_context '収支情報を削除する', PaymentHelper.test_payment[:income][:id]
    it_behaves_like 'ステータスコードが正しいこと', '204'
  end

  describe '異常系' do
    context '存在しないidを指定した場合' do
      include_context '収支情報を削除する', 100
      it_behaves_like 'ステータスコードが正しいこと', '404'
    end
  end
end
