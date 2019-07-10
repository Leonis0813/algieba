# coding: utf-8

require 'rails_helper'

describe Api::CategoriesController, type: :controller do
  shared_context 'カテゴリを検索する' do |param = {}|
    before(:all) do
      @res = client.get('/api/categories', param)
      @response_status = @res.status
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  shared_examples 'レスポンスが正しいこと' do |status: 200, body: nil|
    it 'ステータスコードが正しいこと' do
      is_asserted_by { @response_status == status }
    end

    it 'レスポンスボディが正しいこと' do
      is_asserted_by { @pbody.keys.sort == %w[categories] }

      body[:categories].each_with_index do |category, i|
        is_asserted_by do
          @pbody['categories'][i].keys.sort == CategoryHelper.response_keys
        end

        category.each do |key, value|
          is_asserted_by { @pbody['categories'][i][key.to_s] == value }
        end
      end
    end
  end

  include_context '事前準備: 収支情報を登録する'

  describe '正常系' do
    [
      ['algieba', {categories: [{name: 'algieba', description: nil}]}],
      ['not_exist', {categories: []}],
    ].each do |keyword, expected_body|
      context "#{keyword}を指定した場合" do
        include_context 'カテゴリを検索する', keyword: keyword
        it_behaves_like 'レスポンスが正しいこと', body: expected_body
      end
    end

    context 'keywordを指定しなかった場合' do
      body = {
        categories: Category.all.order(:name).map do |category|
          category.slice(:id, :name, :description)
        end,
      }
      include_context 'カテゴリを検索する'
      it_behaves_like 'レスポンスが正しいこと', body: body
    end
  end
end
