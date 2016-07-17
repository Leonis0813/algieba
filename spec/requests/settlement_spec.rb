# coding: utf-8
require 'rails_helper'

describe '収支を計算する', :type => :request do
  accounts = [
    {:account_type => 'income', :date => '1000-02-01', :content => 'システムテスト用データ', :category => 'システムテスト', :price => 100},
    {:account_type => 'income', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'システムテスト', :price => 1000},
    {:account_type => 'expense', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'システムテスト', :price => 100},
  ]

  include_context '共通設定'

  before(:all) do
    res = @hc.get("#{@base_url}/accounts")
    @accounts = JSON.parse(res.body)
    res = @hc.get("#{@base_url}/accounts")
    ids = JSON.parse(res.body).map {|account| account['id'] }
    ids.each {|id| @hc.delete("#{@base_url}/accounts/#{id}") }
  end

  after(:all) do
    res = @hc.get("#{@base_url}/accounts")
    ids = JSON.parse(res.body).map {|account| account['id'] }
    ids.each {|id| @hc.delete("#{@base_url}/accounts/#{id}") }
    @accounts.each do |account|
      body = {
        :accounts => account.slice('account_type', 'date', 'content', 'category', 'price')
      }.to_json
      @hc.post("#{@base_url}/accounts", body, @content_type_json)
    end
  end

  accounts.each do |account|
    describe '家計簿を登録する' do
      include_context 'POST /accounts', account
      it_behaves_like 'Request: 家計簿が正しく登録されていることを確認する'
    end
  end

  describe '家計簿を検索する' do
    include_context 'GET /accounts'
    it_behaves_like 'Request: 家計簿が正しく検索されていることを確認する'
  end

  [
    ['yearly', {'1000' => 1000}],
    ['monthly', {'1000-01' => 900, '1000-02' => 100}],
    ['daily', {'1000-01-01' => 900, '1000-02-01' => 100}],
  ].each do |interval, expected_settlement|
    describe '収支を計算する' do
      include_context 'GET /settlement', interval
      it_behaves_like 'Request: 収支が正しく計算されていることを確認する', expected_settlement
    end
  end
end
