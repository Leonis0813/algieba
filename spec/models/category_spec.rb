# coding: utf-8

require 'rails_helper'

describe Category, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        category_id: ['0' * 32],
        name: %w[test],
        description: ['test', nil],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        category_id: ['0' * 33, 'g' * 32],
      }

      it_behaves_like '必須パラメーターがない場合のテスト', %i[name]
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
    end
  end
end
