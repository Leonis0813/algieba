# coding: utf-8

require 'rails_helper'

describe PaymentsController, type: :controller do
  describe '#index' do
    shared_context '収支情報を検索する' do |params = {}|
      before do
        get(:index, params: params)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
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
        price_upper: %w[0 10],
        price_lower: %w[0 10],
        sort: %w[payment_id date price],
        page: %w[1 10],
        per_page: %w[1 10],
        order: %w[asc desc],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |params|
        context "#{params.keys.join(',')}を指定する場合" do
          include_context '収支情報を検索する', params
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
        payment_type: ['invalid', ['income'], {type: 'income'}],
        date_before: ['invalid', '1000-13-01', ['1000-01-01'], {date: '1000-01-01'}],
        date_after: ['invalid', '1000-13-01', ['1000-01-01'], {date: '1000-01-01'}],
        content_equal: ['', ['test'], {content: 'test'}],
        content_include: ['', ['test'], {content: 'test'}],
        category: ['', ['test'], {category: 'test'}],
        tag: ['', ['test'], {tag: 'test'}],
        price_upper: ['', '-1', ['0'], {price: '0'}],
        price_lower: ['', '-1', ['0'], {price: '0'}],
        sort: ['invalid', ['date'], {sort: 'date'}],
        page: ['0', 'invalid', ['1'], {page: '1'}],
        per_page: ['0', 'invalid', ['1'], {per_page: '1'}],
        order: ['invalid', ['asc'], {order: 'asc'}],
      }
      CommonHelper.generate_test_case(invalid_attribute).each do |params|
        context "#{params.keys.join(',')}が不正な場合" do
          errors = params.keys.map do |key|
            {
              'error_code' => 'invalid_parameter',
              'parameter' => key.to_s,
              'resource' => nil,
            }
          end
          errors.sort_by! {|error| [error['error_code'], error['parameter']] }
          body = {'errors' => errors}

          include_context '収支情報を検索する', params
          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        end
      end
    end
  end
end
