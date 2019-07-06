# coding: utf-8

require 'rails_helper'

describe Api::DictionariesController, type: :controller do
  shared_context '辞書情報を作成する' do
    before(:all) do
      create(:dictionary) do |dictionary|
        dictionary.categories.create(name: 'include')
      end
      create(:dictionary, phrase: 'test2', condition: 'equal') do |dictionary|
        dictionary.categories.create(name: 'equal')
      end
    end
  end

  shared_context '辞書情報を検索する' do |query|
    before(:all) do
      response = client.get('/api/dictionaries', query)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue nil
    end
  end

  shared_examples 'レスポンスが正常であること' do |status: 200, body: nil|
    before(:all) do
      @response_body = @response_body.tap do |response_body|
        response_body['dictionaries'].map do |dictionary|
          dictionary.except!('id')
          dictionary['categories'].map do |category|
            category.except!('id')
          end
        end
      end
    end

    it 'ステータスコードが正しいこと' do
      is_asserted_by { @response_status == status }
    end

    it 'レスポンスボディが正しいこと' do
      is_asserted_by { @response_body == body }
    end
  end

  describe '正常系' do
    context 'クエリを指定した場合' do
      body = {
        dictionaries: [
          {
            phrase: 'test',
            condition: 'include',
            categories: [
              {name: 'include', description: nil},
            ],
          },
        ],
      }.deep_stringify_keys
      include_context 'トランザクション作成'
      include_context '辞書情報を作成する'
      include_context '辞書情報を検索する', content: 'test'

      it_behaves_like 'レスポンスが正常であること', body: body
    end

    context 'クエリを指定しない場合' do
      body = {
        dictionaries: [
          {
            phrase: 'test2',
            condition: 'equal',
            categories: [
              {name: 'equal', description: nil},
            ],
          },
          {
            phrase: 'test',
            condition: 'include',
            categories: [
              {name: 'include', description: nil},
            ],
          },
        ],
      }.deep_stringify_keys
      include_context 'トランザクション作成'
      include_context '辞書情報を作成する'
      include_context '辞書情報を検索する'

      it_behaves_like 'レスポンスが正常であること', body: body
    end
  end
end
