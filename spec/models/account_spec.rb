# coding: utf-8
require 'rails_helper'

describe Account, :type => :model do
  describe '#settle' do
    accounts = [
      {:account_type => 'income', :date => '1000-01-01', :content => 'モジュールテスト用データ1', :category => 'algieba', :price => 1000},
      {:account_type => 'expense', :date => '1000-01-05', :content => 'モジュールテスト用データ2', :category => 'algieba', :price => 100},
    ]

    before(:all) { accounts.each {|account| Account.create!(account) } }
    after(:all) { Account.delete_all }

    describe '正常系' do
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
  end

  describe '#validates' do
    valid_params = {:account_type => 'income', :date => '1000-01-01', :content => 'モジュールテスト用データ', :category => 'algieba', :price => 1000}

    shared_context 'Accountオブジェクトを検証する' do |params|
      before(:all) do
        @account = Account.new(params)
        @account.validate
      end
    end

    shared_examples '検証結果が正しいこと' do |result|
      it { expect(@account.errors.empty?).to be result }
    end

    describe '正常系' do
      %w[ 1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101 ].each do |date|
        context "date=#{date}の場合" do
          include_context 'Accountオブジェクトを検証する', valid_params.merge(:date => date)
          it_behaves_like '検証結果が正しいこと', true
        end
      end
    end

    describe '異常系' do
      [
        {:account_type => 'invalid_type'},
        {:date => 'invalid_date'},
        {:price => 'invalid_price'},
        {:price => 1.0},
        {:price => -1},
        {:account_type => 'invalid_type', :date => 'invalid_date'},
        {:account_type => 'invalid_type', :price => 'invalid_price'},
        {:account_type => 'invalid_type', :price => 1.0},
        {:account_type => 'invalid_type', :price => -1},
        {:date => 'invalid_date', :price => 'invalid_price'},
        {:date => 'invalid_date', :price => 1.0},
        {:date => 'invalid_date', :price => -1},
        {:account_type => 'invalid_type', :date => 'invalid_date', :price => 'invalid_price'},
        {:account_type => 'invalid_type', :date => 'invalid_date', :price => 1.0},
        {:account_type => 'invalid_type', :date => 'invalid_date', :price => -1},
      ].each do |invalid_params|
        context "#{invalid_params.keys.join(',')}が不正な場合" do
          include_context 'Accountオブジェクトを検証する', valid_params.merge(invalid_params)

          it_behaves_like '検証結果が正しいこと', false

          it 'エラーメッセージが正しいこと' do
            expect(@account.errors.messages).to eq invalid_params.map {|key, _| [key, ['invalid']] }.to_h
          end
        end
      end
    end
  end
end
