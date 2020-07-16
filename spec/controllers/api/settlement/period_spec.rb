# coding: utf-8

require 'rails_helper'

describe Api::SettlementsController, type: :controller do
  render_views

  describe '#period' do
    shared_context '収支を計算する' do |params = {}|
      before do
        get(:period, params: params, format: :json)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    include_context 'トランザクション作成'
    before(:all) do
      category = create(:category, {name: 'algieba'})
      [
        {payment_type: 'income', date: '1000-01-01', price: 1000},
        {payment_type: 'expense', date: '1000-01-05', price: 100},
      ].each do |attribute|
        create(:payment, attribute.merge(categories: [category]))
      end
    end

    describe '正常系' do
      [
        ['yearly', {'settlements' => [{'date' => '1000', 'price' => 900}]}],
        ['monthly', {'settlements' => [{'date' => '1000-01', 'price' => 900}]}],
        [
          'daily',
          {
            'settlements' => [
              {'date' => '1000-01-01', 'price' => 1000},
              {'date' => '1000-01-02', 'price' => 0},
              {'date' => '1000-01-03', 'price' => 0},
              {'date' => '1000-01-04', 'price' => 0},
              {'date' => '1000-01-05', 'price' => -100},
            ],
          },
        ],
      ].each do |interval, expected_body|
        context "#{interval}を指定する場合" do
          include_context '収支を計算する', interval: interval
          it_behaves_like 'レスポンスが正しいこと', body: expected_body
        end
      end
    end

    describe '異常系' do
      ['invalid', %w[yearly], {interval: 'yearly'}].each do |interval|
        context "intervalに#{interval}を指定する場合" do
          body = {
            'errors' => [
              {
                'error_code' => 'invalid_parameter',
                'parameter' => 'interval',
                'resource' => nil,
              },
            ],
          }
          include_context '収支を計算する', interval: interval
          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        end
      end

      context 'intervalパラメーターがない場合' do
        body = {
          'errors' => [
            {
              'error_code' => 'absent_parameter',
              'parameter' => 'interval',
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
