# coding: utf-8

require 'rails_helper'

describe Api::DictionariesController, type: :controller do
  render_views
  dictionary_keys = DictionaryHelper.response_keys - %w[categories]
  category_keys = CategoryHelper.response_keys

  describe '#index' do
    shared_context '辞書情報を検索する' do |params|
      before do
        get(:index, params: params, as: :json)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    include_context 'トランザクション作成'

    before(:all) do
      attribute = {phrase: 'test', categories: [build(:category, name: 'include')]}
      create(:dictionary, attribute)
      attribute = {
        phrase: 'test2',
        condition: 'equal',
        categories: [build(:category, name: 'equal')],
      }
      create(:dictionary, attribute)
    end

    describe '正常系' do
      [
        {condition: 'include'},
        {content: 'test'},
        {phrase: 'test'},
        {condition: 'include', content: 'test', phrase: 'test'},
      ].each do |params|
        context "#{params}を指定した場合" do
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
          include_context '辞書情報を検索する', params
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

    describe '異常系' do
      invalid_attribute = {
        phrase: ['', %w[test], {phrase: 'test'}],
        condition: ['invalid', %w[equal], {condition: 'equal'}],
        content: ['', %w[test], {conten: 'test'}],
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

          include_context '辞書情報を検索する', params
          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        end
      end
    end
  end
end
