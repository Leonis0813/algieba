# coding: utf-8

require 'rails_helper'

describe Dictionary, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        dictionary_id: ['0' * 32],
        phrase: 'phrase',
        condition: %w[equal include],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        dictionary_id: ['0' * 33, 'g' * 32],
        condition: %w[invalid],
      }
      absent_keys = %i[phrase condition]

      it_behaves_like '必須パラメーターがない場合のテスト', absent_keys
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
    end
  end
end
