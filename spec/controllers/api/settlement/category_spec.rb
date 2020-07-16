# coding: utf-8

require 'rails_helper'

describe Api::SettlementsController, type: :controller do
  render_views

  describe '#category' do
    shared_context '収支を計算する' do |params = {}|
      before do
        get(:category, params: params, format: :json)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    include_context 'トランザクション作成'
    before(:all) do
      category = create(:category, {name: 'algieba'})
      [
        {payment_type: 'income', price: 1000},
        {payment_type: 'expense', price: 100},
      ].each do |attribute|
        create(:payment, attribute.merge(categories: [category]))
      end
    end

    describe '正常系' do
      [
        ['income', {'settlements' => [{'category' => 'algieba', 'price' => 1000}]}],
        ['expense', {'settlements' => [{'category' => 'algieba', 'price' => 100}]}],
      ].each do |payment_type, expected_body|
        context "#{payment_type}を指定する場合" do
          include_context '収支を計算する', payment_type: payment_type
          it_behaves_like 'レスポンスが正しいこと', body: expected_body
        end
      end
    end

    describe '異常系' do
      ['invalid', %w[income], {type: 'income'}].each do |payment_type|
        context "payment_typeに#{payment_type}を指定する場合" do
          body = {
            'errors' => [
              {
                'error_code' => 'invalid_parameter',
                'parameter' => 'payment_type',
                'resource' => nil,
              },
            ],
          }
          include_context '収支を計算する', payment_type: payment_type
          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        end
      end

      context 'payment_typeパラメーターがない場合' do
        body = {
          'errors' => [
            {
              'error_code' => 'absent_parameter',
              'parameter' => 'payment_type',
              'resource' => nil,
            },
          ],
        }
        include_context '収支を計算する'
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
      end
    end
  end
end
