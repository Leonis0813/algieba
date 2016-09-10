# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  include_context 'Controller: 共通設定'
  before(:all) { @test_account.each {|_, value| Account.create!(value) } }
  after(:all) { @test_account.each {|_, value| Account.find_by(value).delete } }

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
      [{:account_type => 'expense', :category => 'algieba'}, [:expense]],
      [{:date_before => '1000-01-01', :content_include => 'テスト'}, [:income]],
      [{:date_after => '1000-01-05', :price_upper => 100}, [:expense]],
      [
        {
          :account_type => 'income',
          :date_before => '1000-01-10',
          :date_after => '1000-01-01',
          :content_equal => '機能テスト用データ1',
          :category => 'algieba',
          :price_upper => 100,
          :price_lower => 1000,
        },
        [:income],
      ],
      [{}, [:income, :expense]],
    ].each do |query, expected_accounts|
      description = query.empty? ? '何も指定しない場合' : "#{query.keys.join(',')}を指定する場合"
      context description do
        before(:all) do
          @params = query
          @expected_accounts = expected_accounts.map {|key| @test_account[key].except(:id) }
        end
        include_context 'Controller: 家計簿を検索する'
        it_behaves_like 'Controller: 家計簿が正しく検索されていることを確認する'
      end
    end
  end

  context '異常系' do
    [
      {:account_type => 'invalid_type'},
      {:date_before => 'invalid_date'},
      {:date_after => '1000-13-01'},
      {:price_upper => 'invalid_price'},
      {:price_upper => -100},
      {:price_lower => 100.0},
      {:account_type => 'invalid_type', :date_after => 'invalid_date'},
      {:date_before => '01-13-1000', :price_lower => 'invalid_price'},
      {:account_type => 'invalid_type', :date_after => 'invalid_date', :price_upper => -100},
    ].each do |query|
      context "#{query.keys.join(',')}が不正な場合" do
        before(:all) { @params = query }
        include_context 'Controller: 家計簿を検索する'
        it_behaves_like '400エラーをチェックする', query.map {|key, _| "invalid_param_#{key}" }
      end
    end
  end
end
