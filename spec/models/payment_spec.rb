# coding: utf-8
require 'rails_helper'

describe Payment, :type => :model do
  describe '#settle' do
    payments = [
      {:payment_type => 'income', :date => '1000-01-01', :content => 'モジュールテスト用データ1', :category => 'algieba', :price => 1000},
      {:payment_type => 'expense', :date => '1000-01-05', :content => 'モジュールテスト用データ2', :category => 'algieba', :price => 100},
    ]

    before(:all) { payments.each {|payment| Payment.create!(payment) } }
    after(:all) { Payment.delete_all }

    describe '正常系' do
      [
        ['yearly', {'1000' => 900}],
        ['monthly', {'1000-01' => 900}],
        ['daily', {'1000-01-01' => 1000, '1000-01-05' => -100}],
      ].each do |interval, settlement|
        context "#{interval}を指定する場合" do
          before(:all) { @settlement = Payment.settle(interval) }

          it '計算結果が正しいこと' do
            expect(@settlement).to eq settlement
          end
        end
      end
    end
  end

  describe '#validates' do
    valid_params = {:payment_type => 'income', :date => '1000-01-01', :content => 'モジュールテスト用データ', :category => 'algieba', :price => 1000}

    shared_context 'Paymentオブジェクトを検証する' do |params|
      before(:all) do
        @payment = Payment.new(params)
        @payment.validate
      end
    end

    shared_examples '検証結果が正しいこと' do |result|
      it { expect(@payment.errors.empty?).to be result }
    end

    describe '正常系' do
      %w[ 1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101 ].each do |date|
        context "date=#{date}の場合" do
          include_context 'Paymentオブジェクトを検証する', valid_params.merge(:date => date)
          it_behaves_like '検証結果が正しいこと', true
        end
      end
    end

    describe '異常系' do
      invalid_params = {
        :payment_type => 'invalid_type',
        :date => ['invalid_date', '1000-13-01', '1000-01-00', '1000-13-00'],
        :price => ['invalid_price', 1.0, -1],
      }

      CommonHelper.generate_test_case(invalid_params).each do |invalid_params|
        context "#{invalid_params.keys.join(',')}が不正な場合" do
          include_context 'Paymentオブジェクトを検証する', valid_params.merge(invalid_params)

          it_behaves_like '検証結果が正しいこと', false

          it 'エラーメッセージが正しいこと' do
            expect(@payment.errors.messages).to eq invalid_params.map {|key, _| [key, ['invalid']] }.to_h
          end
        end
      end
    end
  end
end
