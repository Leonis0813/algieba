# coding: utf-8
require 'rails_helper'

describe Payment, type: :model do
  describe '#settle' do
    income = {
      payment_type: 'income',
      date: '1000-01-01',
      content: 'モジュールテスト用データ1',
      category: 'algieba',
      price: 1000,
    }
    expense = {
      payment_type: 'expense',
      date: '1000-01-05',
      content: 'モジュールテスト用データ2',
      category: 'algieba',
      price: 100,
    }

    describe '正常系' do
      [
        ['yearly', [{date: '1000', price: 900}]],
        ['monthly', [{date: '1000-01', price: 900}]],
        ['daily',
         [
           {date: '1000-01-01', price: 1000},
           {date: '1000-01-02', price: 0},
           {date: '1000-01-03', price: 0},
           {date: '1000-01-04', price: 0},
           {date: '1000-01-05', price: -100},
         ],
        ],
      ].each do |interval, settlement|
        context "#{interval}を指定する場合" do
          include_context '事前準備: 収支情報を登録する', [income, expense]
          before(:all) { @settlement = Payment.settle(interval) }
          after(:all) { Payment.destroy_all }

          it '計算結果が正しいこと' do
            is_asserted_by { @settlement == settlement }
          end
        end

        context '収支情報がない場合' do
          before(:all) { @settlement = Payment.settle(interval) }

          it '空配列が返ること' do
            is_asserted_by { @settlement == [] }
          end
        end
      end
    end
  end

  describe '#validates' do
    valid_params = {
      payment_type: 'income',
      date: '1000-01-01',
      content: 'モジュールテスト用データ',
      price: 1000,
    }

    shared_context 'Paymentオブジェクトを検証する' do |params|
      before(:all) do
        @payment = Payment.new(params.except(:category))
        @payment.validate
      end
    end

    shared_examples '検証結果が正しいこと' do |result|
      it_is_asserted_by { @payment.errors.empty? == result }
    end

    describe '正常系' do
      %w[1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101].each do |date|
        context "date=#{date}の場合" do
          include_context 'Paymentオブジェクトを検証する', valid_params.merge(date: date)
          it_behaves_like '検証結果が正しいこと', true
        end
      end
    end

    describe '異常系' do
      invalid_params = {
        payment_type: 'invalid_type',
        date: ['invalid_date', '1000-13-01', '1000-01-00', '1000-13-00'],
        price: ['invalid_price', 1.0, -1],
      }

      CommonHelper.generate_test_case(invalid_params).each do |invalid_params|
        context "#{invalid_params.keys.join(',')}が不正な場合" do
          params = valid_params.merge(invalid_params)
          include_context 'Paymentオブジェクトを検証する', params

          it_behaves_like '検証結果が正しいこと', false

          it 'エラーメッセージが正しいこと' do
            error_messages = invalid_params.map {|key, _| [key, ['invalid']] }.to_h
            is_asserted_by { @payment.errors.messages == error_messages }
          end
        end
      end
    end
  end
end
