# coding: utf-8

require 'rails_helper'

describe '収支情報APIのテスト', type: :request do
  category_name = 'algieba'
  valid_payment = {
    payment_type: 'expense',
    date: '1000-01-01',
    content: 'システムテスト用データ',
    categories: [category_name],
    price: 100,
  }
  invalid_payment = {
    payment_type: 'expense',
    date: 'invalid_date',
    categories: [category_name],
    price: 100,
  }

  shared_context '収支情報を取得する' do
    before(:all) do
      url = "#{base_url}/api/payments/#{@payment_id}"
      res = http_client.get(url, nil, app_auth_header)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  shared_examples '収支情報のレスポンスが正しいこと' do |status: 200|
    it_behaves_like 'ステータスコードが正しいこと', status

    it_is_asserted_by { @response_body.keys.sort == PaymentHelper.response_keys }

    it do
      @response_body['categories'].each do |category|
        is_asserted_by { category.keys.sort == CategoryHelper.response_keys }
      end
    end

    it do
      @response_body['tags'].each do |tag|
        is_asserted_by { tag.keys.sort == TagHelper.response_keys }
      end
    end
  end

  describe '不正な収支情報を作成する' do
    errors = [
      {
        'error_code' => 'absent_parameter',
        'parameter' => 'content',
        'resource' => 'payment',
      },
      {
        'error_code' => 'invalid_parameter',
        'parameter' => 'date',
        'resource' => 'payment',
      },
    ]
    include_context '収支情報を作成する', invalid_payment
    it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
  end

  describe '収支情報を登録する' do
    include_context '収支情報を作成する', valid_payment
    before(:all) { @payment_id = @response_body['payment_id'] }
    it_behaves_like '収支情報のレスポンスが正しいこと', status: 201

    describe '収支情報を取得する' do
      include_context '収支情報を取得する'
      it_behaves_like '収支情報のレスポンスが正しいこと'
    end

    describe '収支情報を更新する' do
      before(:all) do
        url = "#{base_url}/api/payments/#{@payment_id}"
        body = {categories: ['other']}.to_json
        header = app_auth_header.merge(content_type_json)
        res = http_client.put(url, body, header)
        @response_status = res.status
        @response_body = JSON.parse(res.body) rescue res.body
      end

      it_behaves_like '収支情報のレスポンスが正しいこと'

      it '収支情報が更新されていること' do
        is_asserted_by { @response_body['categories'].first['name'] == 'other' }
      end
    end

    describe '収支情報を検索する' do
      query = {
        payment_type: 'income',
        page: 1,
        per_page: 100,
        sort: 'price',
        order: 'desc',
      }
      include_context 'GET /api/payments', query
      it_behaves_like '収支検索時のレスポンスが正しいこと'
    end

    describe '収支情報を削除する' do
      before(:all) do
        url = "#{base_url}/api/payments/#{@payment_id}"
        res = http_client.delete(url, nil, app_auth_header)
        @response_status = res.status
        @response_body = JSON.parse(res.body) rescue res.body
      end

      it_behaves_like 'レスポンスが正しいこと', status: 204, body: ''

      describe '収支情報を取得する' do
        include_context '収支情報を取得する'
        it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
      end
    end
  end
end
