# coding: utf-8

require 'rails_helper'

describe PaymentsController, type: :controller do
  shared_context '収支情報を検索する' do |params = {}|
    before(:all) do
      res = client.get('/management/payments', params)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  describe '正常系' do
    valid_attribute = {
      payment_type: %w[income expense],
      date_before: %w[1000-01-02],
      date_after: %w[1000-01-01],
      content_equal: %w[機能テスト用データ1],
      content_include: %w[機能テスト],
      category: %w[algieba],
      tag: %w[algieba],
      price_upper: [0, 10],
      price_lower: [0, 10],
      sort: %w[payment_id date price],
      page: [1, 10],
      per_page: [1, 10],
      order: %w[asc desc],
    }
    CommonHelper.generate_test_case(valid_attribute).each do |query|
      context "#{query.keys.join(',')}を指定する場合" do
        include_context '収支情報を検索する', query
        it_behaves_like 'ステータスコードが正しいこと', 200
      end
    end

    context '何も指定しない場合' do
      include_context '収支情報を検索する'
      it_behaves_like 'ステータスコードが正しいこと', 200
    end
  end

  describe '異常系' do
    invalid_attribute = {
      page: [0, 'invalid', [1], {page: 1}],
      per_page: [0, 'invalid', [1], {per_page: 1}],
      order: ['invalid', ['asc'], {order: 'asc'}],
      payment_type: ['invalid', ['income'], {type: 'income'}],
      date_before: ['invalid', '1000-13-01', ['1000-01-01'], {date: '1000-01-01'}],
      date_after: ['invalid', '1000-13-01', ['1000-01-01'], {date: '1000-01-01'}],
      content_equal: [['test'], {content: 'test'}],
      content_include: [['test'], {content: 'test'}],
      category: [['test'], {category: 'test'}],
      tag: [['test'], {tag: 'test'}],
      price_upper: [-1, [0], {price: 0}],
      price_lower: [-1, [0], {price: 0}],
      sort: ['invalid', ['date'], {sort: 'date'}],
    }
    CommonHelper.generate_test_case(invalid_attribute).each do |query|
      context "#{query.keys.join(',')}が不正な場合" do
        errors = query.keys.map do |key|
          {
            'error_code' => 'invalid_parameter',
            'parameter' => key.to_s,
            'resource' => nil,
          }
        end
        include_context '収支情報を検索する', query
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end
  end
end
