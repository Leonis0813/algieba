# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  shared_context '収支情報を検索する' do |params = {}|
    before(:all) do
      res = client.get('/api/payments', params)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  include_context '事前準備: 収支情報を登録する'

  describe '正常系' do
    [
      [{payment_type: 'income'}, [:income]],
      [{date_before: '1000-01-01'}, [:income]],
      [{date_after: '1000-01-05'}, [:expense]],
      [{content_equal: '機能テスト用データ1'}, [:income]],
      [{content_include: '機能テスト'}, %i[income expense]],
      [{category: 'algieba'}, %i[income expense]],
      [{price_upper: 100}, %i[income expense]],
      [{price_lower: 100}, [:expense]],
      [{page: 1}, %i[income expense]],
      [{per_page: 1}, [:income]],
      [{sort: 'date'}, %i[income expense]],
      [{order: 'desc'}, %i[expense income]],
      [
        {
          payment_type: 'income',
          date_before: '1000-01-10',
          date_after: '1000-01-01',
          content_equal: '機能テスト用データ1',
          content_include: '機能テスト',
          category: 'algieba',
          price_upper: 100,
          price_lower: 1000,
          page: 1,
          per_page: 1,
          sort: 'price',
          order: 'asc',
        },
        [:income],
      ],
      [{}, %i[income expense]],
    ].each do |query, expected_payment_types|
      description = query.empty? ? '何も指定しない場合' : "#{query.keys.join(',')}を指定する場合"
      expected_payments = expected_payment_types.map do |key|
        payment = PaymentHelper.test_payment[key].except(:id)
        categories = payment[:categories].map do |category_name|
          {name: category_name, description: nil}
        end
        payment.merge(categories: categories)
      end

      context description do
        include_context '収支情報を検索する', query

        it 'ステータスコードが正しいこと' do
          is_asserted_by { @response_status == 200 }
        end

        it 'レスポンスボディが正しいこと' do
          is_asserted_by { @response_body.keys.sort == %w[payments] }

          expected_payments.each_with_index do |payment, i|
            response_payment = @response_body['payments'][i]

            is_asserted_by { response_payment.keys.sort == PaymentHelper.response_keys }

            payment.except(:categories).each do |key, value|
              is_asserted_by { response_payment[key.to_s] == value }
            end

            payment[:categories].each_with_index do |category, j|
              response_category = response_payment['categories'][j]

              is_asserted_by do
                response_category.keys.sort == CategoryHelper.response_keys
              end

              category.each do |key, value|
                is_asserted_by { response_category[key.to_s] == value }
              end
            end
          end
        end
      end
    end

    [
      {date_before: '0999-12-31'},
      {date_after: '1000-12-31'},
      {price_upper: 10000},
      {price_lower: 1},
      {page: 10},
    ].each do |query|
      describe "#{query.keys.join(',')}を指定する場合" do
        include_context '収支情報を検索する', query
        it_behaves_like 'レスポンスが正しいこと', status: 200, body: {'payments' => []}
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
      {page: 'invalid_page'},
      {per_page: 'invalid_per_page'},
      {sort: 'invalid_sort'},
      {order: 'invalid_order'},
      {
        payment_type: 'invalid_type',
        date_before: 'invalid_date',
        date_after: 'invalid_date',
        price_upper: 'invalid_price',
        price_lower: 'invalid_price',
        page: 'invalid_page',
        per_page: 'invalid_per_page',
        sort: 'invalid_sort',
        order: 'invalid_order',
      },
    ].each do |query|
      context "#{query.keys.join(',')}が不正な場合" do
        errors =  query.keys.sort.map {|key| {'error_code' => "invalid_param_#{key}"} }
        include_context '収支情報を検索する', query
        it_behaves_like 'レスポンスが正しいこと', body: {'errors' => errors}
      end
    end
  end
end
