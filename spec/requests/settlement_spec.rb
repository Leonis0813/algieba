# coding: utf-8
require 'rails_helper'

describe '収支を計算する', :type => :request do
  accounts = [
    {:account_type => 'income', :date => '1000-02-01', :content => 'システムテスト用データ', :category => 'システムテスト', :price => 100},
    {:account_type => 'income', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'システムテスト', :price => 1000},
    {:account_type => 'expense', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'システムテスト', :price => 100},
  ]

  before(:all) do
    res = http_client.get("#{base_url}/accounts")
    @accounts = JSON.parse(res.body)
    ids = JSON.parse(res.body).map {|account| account['id'] }
    ids.each {|id| http_client.delete("#{base_url}/accounts/#{id}") }
  end

  after(:all) do
    res = http_client.get("#{base_url}/accounts")
    ids = JSON.parse(res.body).map {|account| account['id'] }
    ids.each {|id| http_client.delete("#{base_url}/accounts/#{id}") }
    @accounts.each do |account|
      body = {:accounts => account.slice(*account_params)}.to_json
      http_client.post("#{base_url}/accounts", body, content_type_json)
    end
  end

  describe '家計簿を登録する' do
    accounts.each {|account| include_context 'POST /accounts', account }

    describe '家計簿を検索する' do
      include_context 'GET /accounts'
      it_behaves_like 'Request: 家計簿が正しく検索されていることを確認する', accounts

      [
        ['yearly', {'1000' => 1000}],
        ['monthly', {'1000-01' => 900, '1000-02' => 100}],
        ['daily', {'1000-01-01' => 900, '1000-02-01' => 100}],
      ].each do |interval, expected_settlement|
        describe '収支を計算する' do
          before(:all) do
            @res = http_client.get("#{base_url}/settlement", :interval => interval)
            @pbody = JSON.parse(@res.body) rescue nil
          end

          it_behaves_like 'ステータスコードが正しいこと', '200'

          it '計算結果が正しいこと' do
            expect(@pbody).to eq expected_settlement
          end
        end
      end
    end
  end
end
