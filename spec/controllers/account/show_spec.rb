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
  before(:all) { @test_account.each {|_, value| Account.create!(value) } }
  after(:all) { @test_account.each {|_, value| Account.find_by(value).delete } }

  context '正常系' do
    before(:all) do
      @id = @test_account[:income][:id]
      @expected_accounts = @test_account[:income].except(:id)
    end
    include_context '家計簿を取得する'

    it_behaves_like 'ステータスコードが正しいこと', '200'

    it 'レスポンスの属性値が正しいこと' do
      actual_account = @pbody.slice(*@account_keys).symbolize_keys
      expect(actual_account).to eq @expected_accounts
    end
  end

  context '異常系' do
    include_context '家計簿を取得する', 100
    it_behaves_like 'ステータスコードが正しいこと', '404'
  end
end
