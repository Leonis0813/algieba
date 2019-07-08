# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  shared_context '収支情報を更新する' do |id, params = {}|
    before(:all) do
      res = client.put("/api/payments/#{id}", params)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  describe '正常系' do
    base_payment = PaymentHelper.test_payment[:income]

    [
      [{payment_type: 'expense'}],
      [{date: '1000-01-02'}],
      [{content: '更新後データ'}],
      [{categories: ['updated']}],
      [{price: 1}],
      [{
        payment_type: 'expense',
        date: '1000-01-02',
        content: '更新後データ',
        categories: ['updated'],
        price: 1,
      }],
      [{}, '更新しない場合'],
    ].each do |param, description|
      context description || "#{param.keys.join(',')}を更新する場合" do
        body = base_payment.merge(param).except(:id)
        response_categories = body[:categories].map do |category_name|
          {name: category_name, description: nil}
        end
        body.merge!(categories: response_categories)
        include_context '事前準備: 収支情報を登録する'
        include_context '収支情報を更新する', base_payment[:id], param
        it_behaves_like '収支リソースのレスポンスが正しいこと', status: 200, body: body
      end
    end

    [
      ['カテゴリリソースが既に存在している場合', categories: ['algieba']],
      ['カテゴリリソースが存在しない場合', categories: ['not_exist']],
      ['複数のカテゴリを指定した場合', categories: %w[algieba other_category]],
    ].each do |description, param|
      context description do
        body = base_payment.merge(param).except(:id)
        response_categories = body[:categories].map do |category_name|
          {name: category_name, description: nil}
        end
        body.merge!(categories: response_categories)
        include_context '事前準備: 収支情報を登録する'
        include_context '収支情報を更新する', base_payment[:id], param
        it_behaves_like '収支リソースのレスポンスが正しいこと', status: 200, body: body
      end
    end
  end

  describe '異常系' do
    [
      {payment_type: 'invalid_type'},
      {date: 'invalid_date'},
      {price: 'invalid_price'},
      {payment_type: 'invalid_type', date: 'invalid_date', price: 'invalid_price'},
    ].each do |params|
      context "#{params.keys.join(',')}が不正な場合" do
        income_id = PaymentHelper.test_payment[:income][:id]
        errors = params.keys.sort.map do |key|
          {'error_code' => "invalid_param_#{key}"}
        end
        include_context '事前準備: 収支情報を登録する'
        include_context '収支情報を更新する', income_id, params
        it_behaves_like 'レスポンスが正しいこと', body: {'errors' => errors}
      end
    end

    context '存在しないidを指定した場合' do
      include_context '収支情報を更新する', 100, payment_type: 'expense'
      it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
    end
  end
end
