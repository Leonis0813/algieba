# coding: utf-8

require 'rails_helper'

describe Category, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        name: %w[test],
        description: ['test', nil],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      it_behaves_like '必須パラメーターがない場合のテスト', %i[name]
    end
  end
end
