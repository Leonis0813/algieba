# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  include_context 'Controller: 共通設定'
  before(:all) do
    @ids = [].tap do |arr|
      @test_account.each do |_, value|
        res = @client.post('/accounts', {:accounts => value})
        arr << JSON.parse(res.body)['id']
      end
    end
  end
  after(:all) { @ids.each {|id| Account.find(id).delete } }

  context '正常系' do
    [
      ['種類を更新する場合', {:account_type => 'expense'}, [:expense]],
      ['内容を更新する場合', {:content => '更新後データ'}, [:income, :expense]],
      ['カテゴリを更新する場合', {:category => '更新後データ'}, [:income, :expense]],
      ['金額を更新する場合', {:price => 10000}, [:income, :expense]],
      ['種類を更新する場合', {'category' => '機能テスト'}, {'account_type' => 'expense'}, [:income, :expense]],
      ['金額を指定してカテゴリを更新する場合', {'price' => 100}, {'category' => '更新'}, [:income, :expense]],
      ['種類と金額を指定してカテゴリを更新する場合', {'account_type' => 'expense', 'price' => 100}, {'category' => '更新'}, [:expense]],
      ['条件を指定せずに金額を更新する場合', nil, {'price' => 10}, [:income, :expense]],
      ['条件を指定せずに内容とカテゴリを更新する場合', nil, {'content' => '更新後データ', 'category' => '更新'}, [:income, :expense]],
    ].each do |description, params, updated_accounts|
      context description do
        before(:all) do
          @test_account.each {|key, value| @client.post('/accounts', {:accounts => value}) }
          @params = {:condition => condition, :with => with}.select {|key, value| value }
          @expected_accounts = updated_accounts.map {|type| @test_account[type].merge(with) }
        end
        include_context 'Controller: 家計簿を更新する'
        it_behaves_like 'Controller: 家計簿が正しく更新されていることを確認する'
        include_context 'Controller: 後始末'
      end
    end
  end

  context '異常系' do
    [
      ['不正な種類を指定する場合', {'account_type' => 'invalid_type'}, {'account_type' => 'expense'}],
      ['不正な日付を指定する場合', {'date' => '01-01-1000'}, {'price' => 1000}],
      ['不正な金額を指定する場合', {'price' => -1}, {'account_type' => 'expense'}],
      ['不正な種類で更新する場合', nil, {'account_type' => 'invalid_type'}],
      ['不正な日付で更新する場合', nil, {'date' => 'invalid_date'}],
      ['不正な金額で更新する場合', nil, {'price' => 100.5}],
    ].each do |description, condition, with|
      context description do
        before(:all) do
          @test_account.each {|key, value| @client.post('/accounts', {:accounts => value}) }
          @params = {:condition => condition, :with => with}.select{|key, value| value }
        end
        include_context 'Controller: 家計簿を更新する'
        it_behaves_like '400エラーをチェックする', (condition || with).keys.map {|key| "invalid_param_#{key}" }
        include_context 'Controller: 後始末'
      end
    end

    context '更新後の値がない場合' do
      before(:all) do
        @test_account.each {|key, value| @client.post('/accounts', {:accounts => value}) }
        @params = {:with => {}}
      end
      include_context 'Controller: 家計簿を更新する'
      it_behaves_like '400エラーをチェックする', ['absent_param_with']
      include_context 'Controller: 後始末'
    end

    context 'with パラメーターがない場合' do
      before(:all) do
        @test_account.each {|key, value| @client.post('/accounts', {:accounts => value}) }
        @params = {}
      end
      include_context 'Controller: 家計簿を更新する'
      it_behaves_like '400エラーをチェックする', ['absent_param_with']
      include_context 'Controller: 後始末'
    end
  end
end
