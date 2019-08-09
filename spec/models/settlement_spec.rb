# coding: utf-8

require 'rails_helper'

describe Settlement, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        interval: %w[yearly monthly daily],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      invalid_attribute = {
        interval: 'invalid',
      }

      it_behaves_like '必須パラメーターがない場合のテスト', %i[interval]
      it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
    end
  end
end
