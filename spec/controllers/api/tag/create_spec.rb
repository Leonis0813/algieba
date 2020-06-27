# coding: utf-8

require 'rails_helper'

describe Api::TagsController, type: :controller do
  default_params = {
    name: 'test',
  }

  shared_context 'タグ情報を登録する' do |params = default_params|
    before(:all) do
      response = client.post('/api/tags', params)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue nil
    end
  end

  shared_examples 'DBにタグ情報が追加されていること' do |query|
    it_is_asserted_by { Tag.exists?(query) }
  end

  shared_examples 'DBにタグ情報が追加されていないこと' do |query|
    it_is_asserted_by { not Tag.exists?(query) }
  end

  describe '正常系' do
    shared_examples 'レスポンスが正しいこと' do |status: 201, body: nil|
      it_behaves_like 'ステータスコードが正しいこと', status

      it 'レスポンスボディが正しいこと' do
        is_asserted_by { @response_body.keys.sort == TagHelper.response_keys }

        body.each do |key, value|
          is_asserted_by { @response_body[key.to_s] == value }
        end
      end
    end

    include_context 'トランザクション作成'
    include_context 'タグ情報を登録する'

    it_behaves_like 'レスポンスが正しいこと', body: default_params
    it_behaves_like 'DBにタグ情報が追加されていること', default_params
  end

  describe '異常系' do
    %i[name].each do |absent_key|
      context "#{absent_key}がない場合" do
        body = {
          'errors' => [
            {
              'error_code' => 'absent_parameter',
              'parameter' => absent_key.to_s,
              'resource' => 'tag',
            },
          ],
        }
        include_context 'タグ情報を登録する', default_params.except(absent_key)

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'DBにタグ情報が追加されていないこと', default_params
      end
    end

    [
      [:name, %w[a b]],
      [:name, 'a' * 11],
    ].each do |invalid_key, value|
      context "#{invalid_key}が不正な場合" do
        params = default_params.merge(invalid_key => value)
        body = {
          'errors' => [
            {
              'error_code' => 'invalid_parameter',
              'parameter' => invalid_key.to_s,
              'resource' => 'tag',
            },
          ],
        }
        include_context 'タグ情報を登録する', params

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'DBにタグ情報が追加されていないこと', params
      end
    end

    context '既に同じタグが登録されている場合' do
      body = {
        'errors' => [
          {
            'error_code' => 'duplicated_resource',
            'parameter' => 'name',
            'resource' => 'tag',
          },
        ],
      }
      include_context 'トランザクション作成'
      before(:all) { create(:tag, default_params) }
      include_context 'タグ情報を登録する'

      it_behaves_like 'レスポンスが正しいこと', status: 400, body: body

      it '辞書が追加されていないこと' do
        is_asserted_by { Tag.where(default_params).count == 1 }
      end
    end
  end
end
