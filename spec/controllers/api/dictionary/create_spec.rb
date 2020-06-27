# coding: utf-8

require 'rails_helper'

describe Api::DictionariesController, type: :controller do
  category_name = 'test'
  default_params = {
    phrase: 'test',
    condition: 'include',
    categories: [category_name],
  }

  shared_context '辞書情報を登録する' do |params = default_params|
    before(:all) do
      response = client.post('/api/dictionaries', params)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue nil
    end
  end

  shared_examples 'DBに辞書情報が追加されていること' do |query|
    it_is_asserted_by { Dictionary.exists?(query) }
  end

  shared_examples 'DBに辞書情報が追加されていないこと' do |query|
    it_is_asserted_by { not Dictionary.exists?(query) }
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

      it 'カテゴリが追加されていないこと' do
        is_asserted_by { Category.where(name: category_name).count == 1 }
      end
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

      it_behaves_like 'レスポンスが正しいこと', body: body
      it_behaves_like 'DBに辞書情報が追加されていること',
                      default_params.except(:categories)

      category_names.each do |name|
        it "name: #{name}のカテゴリが追加されていること" do
          is_asserted_by { Category.exists?(name: name) }
        end
      end
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
        it_behaves_like 'DBに辞書情報が追加されていないこと',
                        default_params.except(:categories)
      end
    end

    %i[phrase condition].each do |invalid_key|
      context "#{invalid_key}が不正な場合" do
        params = default_params.merge(invalid_key => ['invalid'])
        body = {
          'errors' => [
            {
              'error_code' => 'invalid_parameter',
              'parameter' => invalid_key.to_s,
              'resource' => 'dictionary',
            },
          ],
        }
        include_context '辞書情報を登録する', params

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'DBに辞書情報が追加されていないこと', params.except(:categories)
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
      before(:all) do
        dictionary = Dictionary.new(default_params.except(:categories))
        dictionary.categories.build(name: default_params[:categories].first)
        dictionary.save!
      end
      include_context '辞書情報を登録する'

      it_behaves_like 'レスポンスが正しいこと', status: 400, body: body

      it '辞書が追加されていないこと' do
        query = default_params.except(:categories)
        is_asserted_by { Dictionary.where(query).count == 1 }
      end
    end
  end
end
