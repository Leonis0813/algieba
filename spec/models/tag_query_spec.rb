# coding: utf-8

require 'rails_helper'

target = [TagQuery, '#validates']

describe(*target, type: :model) do
  describe '正常系' do
    valid_attribute = {
      name_include: ['test', nil],
    }

    it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
  end

  describe '異常系' do
    invalid_attribute = {
      name_include: [1, ['test'], {name: 'test'}, true],
    }

    CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
      context "#{attribute.keys.join(',')}が不正な場合" do
        expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

        before(:all) do
          @object = build(:tag_query, attribute)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end
end
