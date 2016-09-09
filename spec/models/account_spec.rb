# coding: utf-8
require 'rails_helper'

describe Account, :type => :model do
  income = {
    :id => 1,
    :account_type => 'income',
    :date => '1000-01-01',
    :content => 'モジュールテスト用データ1',
    :category => 'algieba',
    :price => 1000,
  }
  expense = {
    :id => 2,
    :account_type => 'expense',
    :date => '1000-01-05',
    :content => 'モジュールテスト用データ2',
    :category => 'algieba',
    :price => 100,
  }

  before(:all) { [income, expense].each {|account| Account.create!(account) } }
  after(:all) { Account.delete_all }

  context 'settle' do
    context '正常系' do
      [
        ['yearly', {'1000' => 900}],
        ['monthly', {'1000-01' => 900}],
        ['daily', {'1000-01-01' => 1000, '1000-01-05' => -100}],
      ].each do |interval, settlement|
        context "#{interval}を指定する場合" do
          include_context 'Model: 収支を計算する', interval
          it_behaves_like 'Model: 収支が正しく計算されていることを確認する', settlement
        end
      end
    end

    context '異常系' do
      [
        ['invalid_interval', 'invalid'],
        [nil, 'absent'],
      ].each do |interval, expected_message|
        context "#{interval || 'nil'}を指定する場合" do
          it 'Exceptionが発生すること' do
            expect{ Account.settle(interval) }.to raise_error(BadRequest) do |e|
              expect(e.message).to eq expected_message
            end
          end
        end
      end
    end
  end
end
