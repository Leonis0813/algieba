# coding: utf-8

require 'rails_helper'

describe Api::DictionariesController, type: :controller do
  render_views
  category_name = 'test'
  default_params = {
    phrase: 'test',
    condition: 'include',
    categories: [category_name],
  }

  describe '#create' do
    shared_context '辞書情報を登録する' do |params = default_params|
      before do
        @before_dictionary_count = Dictionary.count
        @before_category_count = Category.count
        post(:create, params: params.dup, as: :json)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue nil
      end
    end

    shared_examples 'DBに辞書情報が追加されていること' do |query|
      it_is_asserted_by { Dictionary.count == @before_dictionary_count + 1 }
      it_is_asserted_by { Dictionary.exists?(query) }
    end

    shared_examples 'DBに辞書情報が追加されていないこと' do
      it_is_asserted_by { Dictionary.count == @before_dictionary_count }
    end

    shared_examples 'DBにカテゴリ情報が追加されていること' do |names = []|
      it do
        @after_category_count ||= (@before_category_count + 1)
        is_asserted_by { Category.count == @after_category_count }
      end
      it do
        is_asserted_by do
          Array.wrap(names).all? {|name| Category.exists?(name: name) }
        end
      end
    end

    shared_examples 'DBにカテゴリ情報が追加されていないこと' do
      it_is_asserted_by { Category.count == @before_category_count }
    end

    describe '正常系' do
      shared_examples 'レスポンスが正しいこと' do |status: 201, body: nil|
        it_behaves_like 'ステータスコードが正しいこと', status

        it 'レスポンスボディが正しいこと' do
          is_asserted_by { @response_body.keys.sort == DictionaryHelper.response_keys }

          body.except(:categories).each do |key, value|
            is_asserted_by { @response_body[key.to_s] == value }
          end

          body[:categories].each_with_index do |category, i|
            category.each do |key, value|
              is_asserted_by do
                @response_body['categories'][i].keys.sort == CategoryHelper.response_keys
              end

              is_asserted_by { @response_body['categories'][i][key.to_s] == value }
            end
          end
        end
      end

      context 'カテゴリが存在しない場合' do
        body = default_params.merge(
          categories: [
            {name: category_name, description: nil},
          ],
        )
        include_context 'トランザクション作成'
        include_context '辞書情報を登録する'

        it_behaves_like 'レスポンスが正しいこと', body: body
        it_behaves_like 'DBに辞書情報が追加されていること',
                        default_params.except(:categories)
        it_behaves_like 'DBにカテゴリ情報が追加されていること', category_name
      end

      context 'カテゴリが既に存在する場合' do
        body = default_params.merge(
          categories: [
            {name: category_name, description: nil},
          ],
        )
        include_context 'トランザクション作成'
        before(:all) { create(:category, name: category_name) }
        include_context '辞書情報を登録する'

        it_behaves_like 'レスポンスが正しいこと', body: body
        it_behaves_like 'DBに辞書情報が追加されていること',
                        default_params.except(:categories)
        it_behaves_like 'DBにカテゴリ情報が追加されていないこと'
      end

      context 'カテゴリを複数設定する場合' do
        category_names = [category_name, 'test2']
        body = default_params.merge(
          categories: [
            {name: category_name, description: nil},
            {name: 'test2', description: nil},
          ],
        )
        include_context 'トランザクション作成'
        include_context '辞書情報を登録する',
                        default_params.merge(categories: category_names)
        before { @after_category_count = @before_category_count + 2 }

        it_behaves_like 'レスポンスが正しいこと', body: body
        it_behaves_like 'DBに辞書情報が追加されていること',
                        default_params.except(:categories)
        it_behaves_like 'DBにカテゴリ情報が追加されていること', category_names
      end
    end

    describe '異常系' do
      %i[phrase condition categories].each do |absent_key|
        context "#{absent_key}がない場合" do
          body = {
            'errors' => [
              {
                'error_code' => 'absent_parameter',
                'parameter' => absent_key.to_s,
                'resource' => 'dictionary',
              },
            ],
          }
          include_context '辞書情報を登録する', default_params.except(absent_key)

          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
          it_behaves_like 'DBに辞書情報が追加されていないこと'
          it_behaves_like 'DBにカテゴリ情報が追加されていないこと'
        end
      end

      invalid_attribute = {
        phrase: ['', 1, %w[test], {phrase: 'test'}, true],
        condition: ['invalid', 1, %w[equal], {condition: 'equal'}, true],
        categories: [
          'test',
          1,
          {name: 'test'},
          true,
          [],
          [1],
          [%w[test]],
          [{name: 'test'}],
          [true],
        ],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |invalid_param|
        context "#{invalid_param.keys.join(',')}が不正な場合" do
          params = default_params.merge(invalid_param)
          errors = invalid_param.keys.map do |key|
            {
              'error_code' => 'invalid_parameter',
              'parameter' => key.to_s,
              'resource' => 'dictionary',
            }
          end
          errors.sort_by! {|error| [error['error_code'], error['parameter']] }
          body = {'errors' => errors}

          include_context '辞書情報を登録する', params

          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
          it_behaves_like 'DBに辞書情報が追加されていないこと'
          it_behaves_like 'DBにカテゴリ情報が追加されていないこと'
        end
      end

      context '既に同じ辞書が登録されている場合' do
        body = {
          'errors' => [
            {
              'error_code' => 'duplicated_resource',
              'parameter' => 'phrase',
              'resource' => 'dictionary',
            },
          ],
        }
        include_context 'トランザクション作成'
        before(:all) { create(:dictionary, default_params.slice(:phrase, :condition)) }
        include_context '辞書情報を登録する'

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'DBに辞書情報が追加されていないこと'
        it_behaves_like 'DBにカテゴリ情報が追加されていないこと'
      end

      context '同じ名前のカテゴリが指定されている場合' do
        params = default_params.merge(categories: %w[test test])
        body = {
          'errors' => [
            {
              'error_code' => 'include_same_value',
              'parameter' => 'categories',
              'resource' => 'dictionary',
            },
          ],
        }

        include_context '辞書情報を登録する', params

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'DBに辞書情報が追加されていないこと'
        it_behaves_like 'DBにカテゴリ情報が追加されていないこと'
      end

      context '複合エラーの場合' do
        params = {
          condition: 'invalid',
          categories: %w[test test],
        }
        body = {
          'errors' => [
            {
              'error_code' => 'absent_parameter',
              'parameter' => 'phrase',
              'resource' => 'dictionary',
            },
            {
              'error_code' => 'include_same_value',
              'parameter' => 'categories',
              'resource' => 'dictionary',
            },
            {
              'error_code' => 'invalid_parameter',
              'parameter' => 'condition',
              'resource' => 'dictionary',
            },
          ],
        }

        include_context '辞書情報を登録する', params

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'DBに辞書情報が追加されていないこと'
        it_behaves_like 'DBにカテゴリ情報が追加されていないこと'
      end
    end
  end
end
