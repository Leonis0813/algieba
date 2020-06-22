# coding: utf-8

require 'rails_helper'

describe DictionariesController, type: :controller do
  shared_context '辞書情報を検索する' do |params = {}|
    before(:all) do
      res = client.get('/management/dictionaries', params)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  include_context 'トランザクション作成'
  before(:all) { create(:dictionary) }

  describe '正常系' do
    valid_attribute = {
      phrase_include: %w[機能テスト],
      page: [1, 10],
      per_page: [1, 10],
    }

    CommonHelper.generate_test_case(valid_attribute).each do |query|
      context "#{query.keys.join(',')}を指定する場合" do
        include_context '辞書情報を検索する', query
        it_behaves_like 'ステータスコードが正しいこと', 200
      end
    end

    context '何も指定しない場合' do
      include_context '辞書情報を検索する'
      it_behaves_like 'ステータスコードが正しいこと', 200
    end
  end

  describe '異常系' do
    invalid_attribute = {
      page: [0, 'invalid', [1], {page: 1}],
      per_page: [0, 'invalid', [1], {per_page: 1}],
      phrase_include: [['test'], {phrase: 'test'}],
    }

    CommonHelper.generate_test_case(invalid_attribute).each do |query|
      context "#{query.keys.join(',')}が不正な場合" do
        errors = query.keys.map do |key|
          {'error_code' => 'invalid_parameter', 'parameter' => key.to_s, 'resource' => nil}
        end
        include_context '辞書情報を検索する', query
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end
  end
end
