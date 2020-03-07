# coding: utf-8

require 'rails_helper'

target = [Query, '#validates']

describe(*target, type: :model) do
  describe '正常系' do
    valid_attribute = {
      page: 2,
      per_page: 50,
      order: %w[asc desc],
    }

    it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
  end

  describe '異常系' do
    invalid_attribute = {
      page: [0],
      per_page: [0],
      order: %w[invalid],
    }

    it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute
  end
end
