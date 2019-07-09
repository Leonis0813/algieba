# coding: utf-8

require 'rails_helper'

describe '辞書情報を管理する', type: :request do
  now = Time.now.strftime('%F %T.%6N')
  default_body = {
    phrase: now,
    condition: 'include',
    categories: ['test'],
  }

  shared_context 'POST /api/dictionaries' do |body = default_body|
    before(:all) do
      header = content_type_json.merge('Authorization' => app_auth_header)
      res = http_client.post("#{base_url}/api/dictionaries", body.to_json, header)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  shared_context 'GET /api/dictionaries' do |query = {content: now}|
    before(:all) do
      header = {'Authorization' => app_auth_header}
      res = http_client.get("#{base_url}/api/dictionaries", query, header)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  shared_examples '作成時のレスポンスボディのキーが正しいこと' do
    it_is_asserted_by { @response_status == 201 }

    it do
      is_asserted_by { @response_body.keys.sort == DictionaryHelper.response_keys }

      @response_body['categories'].all? do |category|
        is_asserted_by { category.keys.sort == CategoryHelper.response_keys }
      end
    end
  end

  shared_examples '検索時のレスポンスボディのキーが正しいこと' do
    it_is_asserted_by { @response_status == 200 }

    it do
      is_asserted_by { @response_body.keys.sort == %w[dictionaries] }

      @response_body['dictionaries'].all? do |dictionary|
        is_asserted_by { dictionary.keys.sort == DictionaryHelper.response_keys }

        dictionary['categories'].all? do |category|
          is_asserted_by { category.keys.sort == CategoryHelper.response_keys }
        end
      end
    end
  end

  describe '辞書を検索する' do
    include_context 'GET /api/dictionaries'
    it_behaves_like 'レスポンスが正しいこと', status: 200, body: {'dictionaries' => []}

    describe '辞書を作成する' do
      body = default_body.except(:condition, :categories)
      errors = %i[condition categories].sort.map do |key|
        {'error_code' =>"absent_param_#{key}"}
      end
      include_context 'POST /api/dictionaries', body
      it_behaves_like 'レスポンスが正しいこと', body: {'errors' => errors}

      describe '辞書を作成する' do
        body = default_body.merge(condition: 'invalid')
        errors = [{'error_code' => 'invalid_param_condition'}]
        include_context 'POST /api/dictionaries', body
        it_behaves_like 'レスポンスが正しいこと', body: {'errors' => errors}

        describe '辞書を作成する' do
          include_context 'POST /api/dictionaries'
          it_behaves_like '作成時のレスポンスボディのキーが正しいこと'

          describe '辞書を検索する' do
            include_context 'GET /api/dictionaries'
            it_behaves_like '検索時のレスポンスボディのキーが正しいこと'
          end
        end
      end
    end
  end
end
