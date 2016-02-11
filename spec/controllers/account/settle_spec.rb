# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  income = {'account_type' => 'income', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  expense = {'account_type' => 'expense', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  account_keys = %w[account_type date content category price]

  include_context 'Controller: 共通設定'

  context '正常系' do
    [
      ['年次を指定する場合', 'yearly', {'1000' => 0}],
      ['月次を指定する場合', 'monthly', {'1000-01' => 0}],
      ['日次を指定する場合', 'daily', {'1000-01-01' => 0}],
    ].each do |description, interval, expected_settlement|
      context description do
        before(:all) do
          [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
          @res = @client.get('/settlement', {:interval => interval})
          @pbody = JSON.parse(@res.body)
        end
        after(:all) { @client.delete('/accounts') }

        it_behaves_like 'Controller: 収支が正しく計算されていることを確認する', expected_settlement
      end
    end
  end

  context '異常系' do
    context '不正な期間を指定する場合' do
      before(:all) do
        [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
        @res = @client.get('/settlement', {:interval => 'invalid_interval'})
        @pbody ||= JSON.parse(@res.body)
      end
      after(:all) { @client.delete('/accounts') }

      it_behaves_like '400エラーをチェックする', ['invalid_param_interval']
    end

    context 'interval パラメーターがない場合' do
      before(:all) do
        [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
        @res = @client.get('/settlement')
        @pbody = JSON.parse(@res.body)
      end
      after(:all) { @client.delete('/accounts') }

      it_behaves_like '400エラーをチェックする', ['absent_param_interval']
    end
  end
end
