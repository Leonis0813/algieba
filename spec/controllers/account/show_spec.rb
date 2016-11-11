# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  shared_context '家計簿を取得する' do |id|
    before(:all) do
      @res = client.get("/accounts/#{id}.json")
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: クライアントアプリを作成する'
  include_context '事前準備: 家計簿を登録する'

  describe '正常系' do
    before(:all) { client.header('Authorization', app_auth_header) }
    include_context '家計簿を取得する', CommonHelper.test_account[:income][:id]

    it_behaves_like 'ステータスコードが正しいこと', '200'

    it 'レスポンスの属性値が正しいこと' do
      actual_account = @pbody.slice(*account_params).symbolize_keys
      expected_accounts = test_account[:income].except(:id)
      expect(actual_account).to eq expected_accounts
    end
  end

  describe '異常系' do
    context 'Authorizationヘッダーがない場合' do
      before(:all) { client.header('Authorization', nil) }
      include_context '家計簿を取得する', CommonHelper.test_account[:income][:id]
      it_behaves_like '400エラーをチェックする', ['absent_header']
    end

    context '存在しないidを指定した場合' do
      include_context '家計簿を取得する', 100
      it_behaves_like 'ステータスコードが正しいこと', '404'
    end
  end
end
