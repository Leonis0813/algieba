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
      combinations = CommonHelper.generate_combinations(%i[category_id name])

      combinations.each do |keys|
        context "#{keys.join(',')}が指定されていない場合" do
          before(:all) do
            @object = build(:category, keys.map {|key| [key, nil] }.to_h)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', keys, 'absent_parameter'
        end
      end

      invalid_attribute = {
        category_id: ['0' * 33, 'g' * 32],
      }
      test_cases = CommonHelper.generate_test_case(invalid_attribute)
      test_cases.each do |test_case|
        context "#{test_case.keys.join(',')}が不正な場合" do
          before(:all) do
            @object = build(:category, test_case)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', test_case.keys, 'invalid_parameter'
        end
      end

      combinations.each do |keys|
        context "#{keys.join(',')}が重複している場合" do
          include_context 'トランザクション作成'
          before(:all) do
            category = create(:category)
            @object = build(:category, category.slice(*keys))
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', keys, 'duplicated_resource'
        end
      end
    end
  end
end
