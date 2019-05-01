# coding: utf-8
require 'rails_helper'

describe '収支を計算する', type: :request do
  payment = {
    payment_type: 'income',
    date: '1000-01-01',
    content: 'システムテスト用データ',
    category: 'システムテスト',
    price: 100,
  }

  before(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/api/payments", nil, header)
    @payments = JSON.parse(res.body)
    @payments.each do |payment|
      http_client.delete("#{base_url}/api/payments/#{payment['id']}", nil, header)
    end
  end

  after(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/api/payments", nil, header)
    JSON.parse(res.body).each do |payment|
      http_client.delete("#{base_url}/api/payments/#{payment['id']}", nil, header)
    end

    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    @payments.each do |payment|
      body = {payments: payment.slice(*payment_params)}.to_json
      http_client.post("#{base_url}/api/payments", body, header)
    end
  end

  describe '収支情報を登録する' do
    include_context 'POST /api/payments', payment

    describe '収支情報を検索する' do
      include_context 'GET /api/payments'
      it_behaves_like 'レスポンスボディのキーが正しいこと', PaymentHelper.response_keys

      [
        ['yearly', /\d{4}/],
        ['monthly', /\d{4}-\d{2}/],
        ['daily', /\d{4}-\d{2}-\d{2}/],
      ].each do |interval, regex|
        describe '収支を計算する' do
          before(:all) do
            header = {'Authorization' => app_auth_header}
            @res = http_client.get("#{base_url}/api/settlement", {interval: interval}, header)
            @pbody = JSON.parse(@res.body) rescue nil
          end

          it_behaves_like 'ステータスコードが正しいこと', '200'

          it 'レスポンスボディのキーのフォーマットが正しいこと' do
            @pbody.each {|settlement| is_asserted_by { settlement['date'].match(regex) } }
          end
        end
      end
    end
  end
end
