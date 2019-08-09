# coding: utf-8

require 'rails_helper'

describe Api::CategoriesController, type: :controller do
  shared_context 'カテゴリを検索する' do |param = {}|
    before(:all) do
      res = client.get('/api/categories', param)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  include_context 'トランザクション作成'
  before(:all) { create(:category, name: 'algieba') }

  describe '正常系' do
    %w[algieba not_exist].each do |keyword|
      context "#{keyword}を指定した場合" do
        before(:all) do
          @body = {
            categories: Category.where(:name => keyword).order(:name).map do |category|
              category.slice(:id, :name, :description)
            end,
          }.deep_stringify_keys
        end
        include_context 'カテゴリを検索する', keyword: keyword
        it_behaves_like 'レスポンスが正しいこと'
      end
    end

    context 'keywordを指定しなかった場合' do
      before(:all) do
        @body = {
          categories: Category.all.order(:name).map do |category|
            category.slice(:id, :name, :description)
          end,
        }.deep_stringify_keys
      end
      include_context 'カテゴリを検索する'
      it_behaves_like 'レスポンスが正しいこと'
    end
  end
end
