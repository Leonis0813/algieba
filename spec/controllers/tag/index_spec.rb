# coding: utf-8

require 'rails_helper'

describe TagsController, type: :controller do
  describe '#index' do
    shared_context 'タグ情報を検索する' do |params = {}|
      before do
        get(:index, params: params)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    describe '正常系' do
      valid_attribute = {
        name_include: %w[機能テスト],
        page: %w[1 10],
        per_page: %w[1 10],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |params|
        context "#{params.keys.join(',')}を指定する場合" do
          include_context 'タグ情報を検索する', params
          it_behaves_like 'ステータスコードが正しいこと', 200
        end
      end

      context '何も指定しない場合' do
        include_context 'タグ情報を検索する'
        it_behaves_like 'ステータスコードが正しいこと', 200
      end
    end

    describe '異常系' do
      invalid_attribute = {
        page: [0, 'invalid', [1], {page: 1}],
        per_page: [0, 'invalid', [1], {per_page: 1}],
        name_include: ['', ['test'], {name: 'test'}],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |params|
        context "#{params.keys.join(',')}が不正な場合" do
          errors = params.keys.map do |key|
            {
              'error_code' => 'invalid_parameter',
              'parameter' => key.to_s,
              'resource' => nil,
            }
          end.sort_by {|error| [error['error_code'], error['parameter']] }
          body = {'errors' => errors}

          include_context 'タグ情報を検索する', params
          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        end
      end
    end
  end
end
