# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  include_context 'Controller: 共通設定'

  context '正常系' do
    [
      ['年次を指定する場合', 'yearly', {'1000' => 0}],
      ['月次を指定する場合', 'monthly', {'1000-01' => 0}],
      ['日次を指定する場合', 'daily', {'1000-01-01' => 0}],
    ].each do |description, interval, expected_settlement|
      context description do
        before(:all) do
          @test_account.each {|key, value| @client.post('/accounts', {:accounts => value}) }
          @params = {:interval => interval}
        end
        include_context 'Controller: 収支を計算する'
        it_behaves_like 'Controller: 収支が正しく計算されていることを確認する', expected_settlement
        include_context 'Controller: 後始末'
      end
    end
  end

  context '異常系' do
    context '不正な期間を指定する場合' do
      before(:all) do
        @test_account.each {|key, value| @client.post('/accounts', {:accounts => value}) }
        @params = {:interval => 'invalid_internal'}
      end
      include_context 'Controller: 収支を計算する'
      it_behaves_like '400エラーをチェックする', ['invalid_param_interval']
      include_context 'Controller: 後始末'
    end

    context 'interval パラメーターがない場合' do
      before(:all) do
        @test_account.each {|key, value| @client.post('/accounts', {:accounts => value}) }
        @params = {}
      end
      include_context 'Controller: 収支を計算する'
      it_behaves_like '400エラーをチェックする', ['absent_param_interval']
      include_context 'Controller: 後始末'
    end
  end
end
