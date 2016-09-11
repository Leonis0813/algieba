# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  shared_context '家計簿を取得する' do |id|
    before(:all) do
      @res = @client.get("/accounts/#{id || @id}.json")
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context 'Controller: 共通設定'
  include_context '事前準備: 家計簿を登録する'

  context '正常系' do
    before(:all) { @id = @test_account[:income][:id] }

    include_context '家計簿を取得する'

    it_behaves_like 'ステータスコードが正しいこと', '200'

    it 'レスポンスの属性値が正しいこと' do
      actual_account = @pbody.slice(*@account_keys).symbolize_keys
      expected_accounts = @test_account[:income].except(:id)
      expect(actual_account).to eq expected_accounts
    end
  end

  context '異常系' do
    include_context '家計簿を取得する', 100
    it_behaves_like 'ステータスコードが正しいこと', '404'
  end
end