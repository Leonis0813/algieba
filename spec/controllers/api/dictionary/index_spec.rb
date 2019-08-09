# coding: utf-8

require 'rails_helper'

describe Api::DictionariesController, type: :controller do
  shared_context '辞書情報を検索する' do |query|
    before(:all) do
      response = client.get('/api/dictionaries', query)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue nil
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
    context 'クエリを指定した場合' do
      before(:all) do
        dictionaries = Dictionary.where(phrase: 'test', condition: 'include')
        @body = {
          dictionaries: dictionaries.map do |dictionary|
            dictionary.slice(:id, :phrase, :condition).merge(
              categories: dictionary.categories.map do |category|
                category.slice(:id, :name, :description)
              end,
            )
          end,
        }.deep_stringify_keys
      end
      include_context '辞書情報を検索する', content: 'test'
      it_behaves_like 'レスポンスが正しいこと'
    end

    context 'クエリを指定しない場合' do
      before(:all) do
        @body = {
          dictionaries: Dictionary.all.order(:condition).map do |dictionary|
            categories = dictionary.categories.map do |category|
              category.slice(:id, :name, :description)
            end
            dictionary.slice(:id, :phrase, :condition).merge(categories: categories)
          end,
        }.deep_stringify_keys
      end
      include_context '辞書情報を検索する'
      it_behaves_like 'レスポンスが正しいこと'
    end
  end
end
