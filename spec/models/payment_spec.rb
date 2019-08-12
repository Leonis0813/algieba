# coding: utf-8

require 'rails_helper'

describe Payment, type: :model do
  describe '#settle' do
    income = {
      payment_type: 'income',
      date: '1000-01-01',
      content: 'モジュールテスト用データ1',
      categories: ['algieba'],
      price: 1000,
    }
    expense = {
      payment_type: 'expense',
      date: '1000-01-05',
      content: 'モジュールテスト用データ2',
      categories: ['algieba'],
      price: 100,
    }

    describe '正常系' do
      [
        ['yearly', [{date: '1000', price: 900}]],
        ['monthly', [{date: '1000-01', price: 900}]],
        [
          'daily',
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
          include_context '収支情報を登録する', [income, expense]
          before(:all) { @settlement = Payment.settle(interval) }

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
    describe '正常系' do
      valid_attribute = {
        payment_type: %w[income expense],
        date: %w[1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101],
        content: 'モジュールテスト用データ',
        price: 0,
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        payment_type: 'invalid',
        date: %w[invalid 1000-13-01 1000-01-00 1000-13-00],
        price: [-1],
      }
      absent_keys = %i[payment_type content price]

      it_behaves_like '必須パラメーターがない場合のテスト', absent_keys
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
    end
  end
end
