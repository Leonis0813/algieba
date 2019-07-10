# coding: utf-8

require 'rails_helper'

describe PaymentsController, type: :controller do
  shared_context '収支情報を検索する' do |params = {}|
    before(:all) do
      res = client.get('/payments', params)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  include_context '事前準備: 収支情報を登録する'

  describe '正常系' do
    [
      {payment_type: 'income'},
      {date_before: '1000-01-01'},
      {date_after: '1000-01-05'},
      {content_equal: '機能テスト用データ1'},
      {content_include: '機能テスト'},
      {category: 'algieba'},
      {price_upper: 100},
      {price_lower: 100},
      {per_page: 10},
      {
        payment_type: 'income',
        date_before: '1000-01-10',
        date_after: '1000-01-01',
        content_equal: '機能テスト用データ1',
        content_include: '機能テスト',
        category: 'algieba',
        price_upper: 100,
        price_lower: 1000,
        per_page: 10,
      },
      {},
    ].each do |query|
      description = query.empty? ? '何も指定しない場合' : "#{query.keys.join(',')}を指定する場合"

      context description do
        include_context '収支情報を検索する', query

        it 'ステータスコードが正しいこと' do
          is_asserted_by { @response_status == 200 }
        end
      end
    end
  end

  describe '異常系' do
    [
      {payment_type: 'invalid_type'},
      {date_before: 'invalid_date'},
      {date_after: 'invalid_date'},
      {price_upper: 'invalid_price'},
      {price_lower: 'invalid_price'},
      {per_page: 'invalid_per_page'},
      {
        payment_type: 'invalid_type',
        date_before: 'invalid_date',
        date_after: 'invalid_date',
        price_upper: 'invalid_price',
        price_lower: 'invalid_price',
      },
    ].each do |query|
      context "#{query.keys.join(',')}が不正な場合" do
        errors = query.keys.sort.map {|key| {'error_code' => "invalid_param_#{key}"} }
        include_context '収支情報を検索する', query
        it_behaves_like 'レスポンスが正しいこと', body: {'errors' => errors}
      end
    end
  end
end
