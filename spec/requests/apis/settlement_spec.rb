# coding: utf-8

require 'rails_helper'

describe '収支を計算する', type: :request do
  test_payment = {
    payment_type: 'income',
    date: '1000-01-01',
    content: 'システムテスト用データ',
    categories: ['システムテスト'],
    price: 100,
  }

  before(:all) { delete_payments }
  after(:all) { delete_payments }

  describe '収支情報を登録する' do
    include_context 'POST /api/payments', test_payment

    describe '収支情報を検索する' do
      include_context 'GET /api/payments'
      it_behaves_like '収支検索時のレスポンスが正しいこと'

      [
        ['yearly', /\d{4}/],
        ['monthly', /\d{4}-\d{2}/],
        ['daily', /\d{4}-\d{2}-\d{2}/],
      ].each do |interval, regex|
        describe '期間別で収支を計算する' do
          before(:all) do
            body = {interval: interval}
            header = app_auth_header
            res = http_client.get("#{base_url}/api/settlements/period", body, header)
            @response_status = res.status
            @response_body = JSON.parse(res.body) rescue res.body
          end

          it_behaves_like 'ステータスコードが正しいこと', 200

          it 'レスポンスボディのキーのフォーマットが正しいこと' do
            @response_body['settlements'].each do |settlement|
              is_asserted_by { settlement['date'].match(regex) }
            end
          end
        end
      end

      [
        ['income', [{'category' => 'システムテスト', 'price' => 100}]],
        ['expense', []],
      ].each do |payment_type, expected_settlements|
        describe 'カテゴリ別で収支を計算する' do
          before(:all) do
            body = {payment_type: payment_type}
            header = app_auth_header
            res = http_client.get("#{base_url}/api/settlements/category", body, header)
            @response_status = res.status
            @response_body = JSON.parse(res.body) rescue res.body
          end

          it_behaves_like 'ステータスコードが正しいこと', 200

          it 'レスポンスボディのキーのフォーマットが正しいこと' do
            is_asserted_by { @response_body['settlements'] == expected_settlements }
          end
        end
      end
    end
  end
end
