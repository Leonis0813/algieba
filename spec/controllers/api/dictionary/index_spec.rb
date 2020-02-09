# coding: utf-8

require 'rails_helper'

describe Api::DictionariesController, type: :controller do
  dictionary_keys = DictionaryHelper.response_keys - %w[categories]
  category_keys = CategoryHelper.response_keys

  shared_context '辞書情報を検索する' do |query|
    before(:all) do
      response = client.get('/api/dictionaries', query)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue response.body
    end
  end

  include_context 'トランザクション作成'

  before(:all) do
    create(:dictionary) {|dictionary| dictionary.categories.create(name: 'include') }
    create(:dictionary, phrase: 'test2', condition: 'equal') do |dictionary|
      dictionary.categories.create(name: 'equal')
    end
  end

  describe '正常系' do
    [
      {condition: 'include'},
      {content: 'test'},
      {phrase: 'test'},
      {condition: 'include', content: 'test', phrase: 'test'},
    ].each do |query|
      context "#{query}を指定した場合" do
        before(:all) do
          dictionaries = Dictionary.where(phrase: 'test', condition: 'include')
          @body = {
            dictionaries: dictionaries.map do |dictionary|
              dictionary.slice(*dictionary_keys).merge(
                categories: dictionary.categories.map do |category|
                  category.slice(*category_keys)
                end,
              )
            end,
          }.deep_stringify_keys
        end
        include_context '辞書情報を検索する', query
        it_behaves_like 'レスポンスが正しいこと'
      end
    end

    context 'クエリを指定しない場合' do
      before(:all) do
        @body = {
          dictionaries: Dictionary.all.order(:condition).map do |dictionary|
            categories = dictionary.categories.map do |category|
              category.slice(*category_keys)
            end
            dictionary.slice(*dictionary_keys).merge(categories: categories)
          end,
        }.deep_stringify_keys
      end
      include_context '辞書情報を検索する'
      it_behaves_like 'レスポンスが正しいこと'
    end
  end
end
