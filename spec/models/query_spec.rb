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
    test_cases = CommonHelper.generate_test_case(invalid_attribute)
    test_cases.each do |test_case|
      context "#{test_case.keys.join(',')}が不正な場合" do
        expected_error = test_case.keys.map do |key|
          [key, 'invalid_parameter']
        end.to_h

        before(:all) do
          @object = build(:query, test_case)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end
end
