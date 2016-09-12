# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  shared_context '家計簿を検索する' do |params|
    before(:all) do
      @res = client.get('/accounts.json', params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: 家計簿を登録する'

  context '正常系' do
    [
      [{:account_type => 'income'}, [:income]],
      [{:date_before => '1000-01-01'}, [:income]],
      [{:date_after => '1000-01-05'}, [:expense]],
      [{:content_equal => '機能テスト用データ1'}, [:income]],
      [{:content_include => '機能テスト'}, [:income, :expense]],
      [{:category => 'algieba'}, [:income, :expense]],
      [{:price_upper => 100}, [:income, :expense]],
      [{:price_lower => 100}, [:expense]],
      [
        {
          :account_type => 'income',
          :date_before => '1000-01-10',
          :date_after => '1000-01-01',
          :content_equal => '機能テスト用データ1',
          :content_include => '機能テスト',
          :category => 'algieba',
          :price_upper => 100,
          :price_lower => 1000,
        },
        [:income],
      ],
      [{}, [:income, :expense]],
    ].each do |query, expected_account_types|
      description = query.empty? ? '何も指定しない場合' : "#{query.keys.join(',')}を指定する場合"

      context description do
        include_context '家計簿を検索する', query

        it_behaves_like 'ステータスコードが正しいこと', '200'

        it 'レスポンスの属性値が正しいこと' do
          actual_accounts = @pbody.map {|account| account.slice(*account_params).symbolize_keys }
          expected_accounts = expected_account_types.map {|key| test_account[key].except(:id) }
          expect(actual_accounts).to eq expected_accounts
        end
      end
    end
  end

  context '異常系' do
    [
      {:account_type => 'invalid_type'},
      {:date_before => 'invalid_date'},
      {:date_after => 'invalid_date'},
      {:price_upper => 'invalid_price'},
      {:price_lower => 'invalid_price'},
      {:account_type => 'invalid_type', :date_before => 'invalid_date', :date_after => 'invalid_date', :price_upper => 'invalid_price', :price_lower => 'invalid_price'},
    ].each do |query|
      context "#{query.keys.join(',')}が不正な場合" do
        include_context '家計簿を検索する', query
        it_behaves_like '400エラーをチェックする', query.map {|key, _| "invalid_param_#{key}" }
      end
    end
  end
end
