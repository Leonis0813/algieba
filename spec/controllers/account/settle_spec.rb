# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  include_context 'Controller: 共通設定'
  before(:all) { @test_account.each {|_, value| Account.create!(value) } }
  after(:all) { @test_account.each {|_, value| Account.find_by(value).delete } }

  context '正常系' do
    [
      ['yearly', {'1000' => 900}],
      ['monthly', {'1000-01' => 900}],
      ['daily', {'1000-01-01' => 1000, '1000-01-05' => -100}],
    ].each do |interval, expected_settlement|
      context "#{interval}を指定する場合" do
        before(:all) { @params = {:interval => interval} }
        include_context 'Controller: 収支を計算する'
        it_behaves_like 'Controller: 収支が正しく計算されていることを確認する', expected_settlement
      end
    end
  end

  context '異常系' do
    context '不正な期間を指定する場合' do
      before(:all) { @params = {:interval => 'invalid_interval'} }
      include_context 'Controller: 収支を計算する'
      it_behaves_like '400エラーをチェックする', ['invalid_param_interval']
    end

    context 'interval パラメーターがない場合' do
      before(:all) { @params = {} }
      include_context 'Controller: 収支を計算する'
      it_behaves_like '400エラーをチェックする', ['absent_param_interval']
    end
  end
end
