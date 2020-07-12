# coding: utf-8

require 'rails_helper'

describe Api::CategoriesController, type: :controller do
  render_views

  describe '#index' do
    shared_context 'カテゴリを検索する' do |params = {}|
      before do
        get(:index, params: params, format: :json)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    include_context 'トランザクション作成'
    before(:all) { create(:category, name: 'algieba') }

    describe '正常系' do
      %w[algieba not_exist].each do |keyword|
        context "#{keyword}を指定した場合", :wip do
          before(:all) do
            @body = {
              categories: Category.where(name: keyword).order(:name).map do |category|
                category.slice(:category_id, :name, :description)
              end,
            }.deep_stringify_keys
          end
          include_context 'カテゴリを検索する', keyword: 1
          it_behaves_like 'レスポンスが正しいこと'
        end
      end

      context 'keywordを指定しなかった場合' do
        before(:all) do
          @body = {
            categories: Category.all.order(:name).map do |category|
              category.slice(:category_id, :name, :description)
            end,
          }.deep_stringify_keys
        end
        include_context 'カテゴリを検索する'
        it_behaves_like 'レスポンスが正しいこと'
      end
    end

    describe '異常系' do
      ['', %w[algieba], {keyword: 'algieba'}].each do |keyword|
        context "keywordに#{keyword}を指定した場合" do
          body = {
            'errors' => [
              {
                'error_code' => 'invalid_parameter',
                'parameter' => 'keyword',
                'resource' => nil,
              },
            ],
          }
          include_context 'カテゴリを検索する', keyword: keyword
          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        end
      end
    end
  end
end
