# coding: utf-8

require 'rails_helper'

describe CategoriesController, type: :controller do
  shared_context 'カテゴリ情報を検索する' do |params = {}|
    before(:all) do
      res = client.get('/management/categories', params)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  include_context 'トランザクション作成'

  before(:all) { create(:category) }

  describe '正常系' do
    [
      {name_include: '機能テスト'},
      {page: 1},
      {per_page: 10},
      {name_include: '機能テスト', page: 1, per_page: 10},
      {},
    ].each do |query|
      description = query.empty? ? '何も指定しない場合' : "#{query.keys.join(',')}を指定する場合"

      context description do
        include_context 'カテゴリ情報を検索する', query
        it_behaves_like 'ステータスコードが正しいこと', 200
      end
    end
  end

  describe '異常系' do
    [
      {page: 'invalid'},
      {per_page: 'invalid'},
      {page: 'invalid', per_page: 'invalid'},
    ].each do |query|
      context "#{query.keys.join(',')}が不正な場合" do
        errors = query.keys.sort.map {|key| {'error_code' => "invalid_param_#{key}"} }
        include_context 'カテゴリ情報を検索する', query
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end
  end
end
