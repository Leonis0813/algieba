# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  include_context 'Controller: 共通設定'
  before(:all) { @test_account.each {|key, value| @client.post('/accounts', {:accounts => value}) } }
  include_context 'Controller: 後始末'

  context '正常系' do
    [
      ['種類を指定する場合', {:account_type => 'income'}, [:income]],
      ['日付を指定する場合', {:date => '1000-01-01'}, [:income, :expense]],
      ['内容を指定する場合', {:content => '機能テスト用データ'}, [:income, :expense]],
      ['カテゴリを指定する場合', {:category => '機能テスト'}, [:income, :expense]],
      ['金額を指定する場合', {:price => 100}, [:income, :expense]],
      ['種類とカテゴリを指定する場合', {:account_type => 'income', :category => '機能テスト'}, [:income]],
      ['条件を指定しない場合', {}, [:income, :expense]],
    ].each do |description, condition, expected_accounts|
      context description do
        before(:all) do
          @params = condition
          @expected_accounts = expected_accounts.map {|type| @test_account[type] }
        end
        include_context 'Controller: 家計簿を取得する'
        it_behaves_like 'Controller: 家計簿が正しく取得されていることを確認する', expected_accounts
      end
    end
  end

  context '異常系' do
    [
      ['不正な種類を指定する場合', {'account_type' => 'invalid_type'}],
      ['不正な日付を指定する場合', {'date' => 'invalid_date'}],
      ['不正な金額を指定する場合', {'price' => 'invalid_price'}],
    ].each do |description, condition|
      context description do
        before(:all) { @params = condition }
        include_context 'Controller: 家計簿を取得する'
        it_behaves_like '400エラーをチェックする', condition.keys.map {|key| "invalid_param_#{key}" }
      end
    end
  end
end
