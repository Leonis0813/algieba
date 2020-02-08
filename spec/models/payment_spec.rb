# coding: utf-8

require 'rails_helper'

describe Payment, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        payment_id: ['0' * 32],
        payment_type: %w[income expense],
        date: %w[1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101],
        content: 'モジュールテスト用データ',
        price: 0,
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        payment_id: ['0' * 33, 'g' * 32],
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
