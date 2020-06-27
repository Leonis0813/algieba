# coding: utf-8

require 'rails_helper'

describe Api::SettlementsController, type: :controller do
  shared_context '収支を計算する' do |params = {}|
    before(:all) do
      res = client.get('/api/settlements/period', params)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
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
    [[nil, 'absent'], %w[invalid_interval invalid]].each do |interval, message|
      context "#{interval || 'nil'}を指定する場合" do
        body = {
          'errors' => [
            {
              'error_code' => "#{message}_parameter",
              'parameter' => 'interval',
              'resource' => nil,
            },
          ],
        }
        include_context '収支を計算する', interval: interval
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
      end
    end

    context 'interval パラメーターがない場合' do
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
