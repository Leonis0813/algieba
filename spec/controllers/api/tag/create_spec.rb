# coding: utf-8

require 'rails_helper'

describe Api::TagsController, type: :controller do
  render_views
  default_params = {name: 'test'}

  describe '#create' do
    shared_context 'タグ情報を登録する' do |params = default_params|
      before do
        @before_count = Tag.count
        post(:create, params: params.dup, as: :json)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    shared_examples 'DBにタグ情報が追加されていること' do |query = default_params|
      it_is_asserted_by { Tag.count == @before_count + 1 }
      it_is_asserted_by { Tag.exists?(query) }
    end

    shared_examples 'DBにタグ情報が追加されていないこと' do
      it_is_asserted_by { Tag.count == @before_count }
    end

    describe '正常系' do
      shared_examples 'レスポンスが正しいこと' do |status: 201, body: default_params|
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

      it_behaves_like 'レスポンスが正しいこと'
      it_behaves_like 'DBにタグ情報が追加されていること'
    end

    describe '異常系' do
      context 'nameがない場合' do
        body = {
          'errors' => [
            {
              'error_code' => 'absent_parameter',
              'parameter' => 'name',
              'resource' => 'tag',
            },
          ],
        }
        include_context 'タグ情報を登録する', {}

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'DBにタグ情報が追加されていないこと'
      end

      ['', 'a' * 11, 1, ['a'], {name: 'a'}, true].each do |name|
        context "nameに#{name}を指定した場合" do
          params = default_params.merge(name: name)
          body = {
            'errors' => [
              {
                'error_code' => 'invalid_parameter',
                'parameter' => 'name',
                'resource' => 'tag',
              },
            ],
          }
          include_context 'タグ情報を登録する', params

          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
          it_behaves_like 'DBにタグ情報が追加されていないこと'
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
        it_behaves_like 'DBにタグ情報が追加されていないこと'
      end
    end
  end
end
