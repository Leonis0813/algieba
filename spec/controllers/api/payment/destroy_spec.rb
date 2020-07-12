# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  describe '#destroy' do
    shared_context '収支情報を削除する' do |payment_id|
      before do
        payment_id ||= @payment_id
        delete(:destroy, params: {payment_id: payment_id})
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    include_context 'トランザクション作成'
    before(:all) { @payment = create(:payment) }

    describe '正常系' do
      before(:all) { @payment_id = @payment.payment_id }
      include_context '収支情報を削除する'

      it_behaves_like 'レスポンスが正しいこと', status: 204, body: ''
      it 'DBから収支情報が削除されていること' do
        is_asserted_by { not Payment.exists?(payment_id: @payment.payment_id) }
      end
    end

    describe '異常系' do
      context '存在しないidを指定した場合' do
        include_context '収支情報を削除する', 'not_exist'

        it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
        it 'DBから収支情報が削除されていないこと' do
          is_asserted_by { Payment.exists?(payment_id: @payment.payment_id) }
        end
      end
    end
  end
end
