# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  base_payment = PaymentHelper.test_payment[:income]
  category_keys = CategoryHelper.response_keys

  shared_context '収支情報を更新する' do |payment_id: nil, body: {}|
    before(:all) do
      payment_id ||= @payment_id
      res = client.put("/api/payments/#{payment_id}", body)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  describe '正常系' do
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
    ].each do |body, description|
      context description || "#{body.keys.join(',')}を更新する場合" do
        include_context '収支情報を登録する'
        before(:all) { @payment_id = Payment.find(base_payment[:id]).payment_id }
        include_context '収支情報を更新する', body: body
        before(:all) do
          response_body = base_payment.except(:id).merge(body)
          categories = response_body[:categories].map do |category_name|
            Category.find_by(name: category_name).slice(*category_keys)
          end
          tags = response_body[:tags].map do |tag_name|
            Tag.find_by(name: tag_name).slice(:tag_id, :name)
          end
          @body = response_body.merge(
            payment_id: @payment_id,
            categories: categories,
            tags: tags,
          ).deep_stringify_keys
        end

        it_behaves_like 'レスポンスが正しいこと'
      end
    end

    [
      ['カテゴリリソースが既に存在している場合', categories: ['algieba']],
      ['カテゴリリソースが存在しない場合', categories: ['not_exist']],
      ['複数のカテゴリを指定した場合', categories: %w[algieba other_category]],
    ].each do |description, body|
      context description do
        include_context '収支情報を登録する'
        before(:all) { @payment_id = Payment.find(base_payment[:id]).payment_id }
        include_context '収支情報を更新する', body: body
        before(:all) do
          response_body = base_payment.except(:id).merge(body)
          categories = response_body[:categories].map do |category_name|
            Category.find_by(name: category_name).slice(*category_keys)
          end
          tags = response_body[:tags].map do |tag_name|
            Tag.find_by(name: tag_name).slice(:tag_id, :name)
          end
          @body = response_body.merge(
            payment_id: @payment_id,
            categories: categories,
            tags: tags,
          ).deep_stringify_keys
        end

        it_behaves_like 'レスポンスが正しいこと'
      end
    end
  end

  describe '異常系' do
    [
      {payment_type: 'invalid_type'},
      {date: 'invalid_date'},
      {price: 'invalid_price'},
      {payment_type: 'invalid_type', date: 'invalid_date', price: 'invalid_price'},
    ].each do |body|
      context "#{body.keys.join(',')}が不正な場合" do
        errors = body.keys.sort.map do |key|
          {'error_code' => "invalid_param_#{key}"}
        end
        include_context '収支情報を登録する'
        before(:all) { @payment_id = Payment.find(base_payment[:id]).payment_id }
        include_context '収支情報を更新する', body: body
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end

    context '存在しないidを指定した場合' do
      include_context '収支情報を更新する', payment_id: 'not_exist'
      it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
    end
  end
end
