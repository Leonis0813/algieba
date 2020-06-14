# coding: utf-8

require 'rails_helper'

describe Dictionary, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        dictionary_id: ['0' * 32],
        phrase: %w[phrase],
        condition: %w[equal include],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      attribute_names = %i[dictionary_id phrase condition categories]
      blank_value = {categories: []}
      combinations = CommonHelper.generate_combinations(attribute_names)

      combinations.each do |keys|
        context "#{keys.join(',')}が指定されていない場合" do
          before(:all) do
            @object = build(:dictionary, keys.map {|key| [key, blank_value[key]] }.to_h)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', keys, 'absent_parameter'
        end
      end

      invalid_attribute = {
        dictionary_id: ['0' * 33, 'g' * 32],
        condition: %w[invalid],
      }
      test_cases = CommonHelper.generate_test_case(invalid_attribute)
      test_cases.each do |test_case|
        context "#{test_case.keys.join(',')}が不正な場合" do
          before(:all) do
            @object = build(:dictionary, test_case)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', test_case.keys, 'invalid_parameter'
        end
      end

      [
        [:dictionary_id],
        [:phrase, :condition],
        [:dictionary_id, :phrase, :condition],
      ].each do |keys|
        error_keys = keys - [:condition]

        context "#{keys.join(',')}が重複している場合" do
          include_context 'トランザクション作成'
          before(:all) do
            dictionary = create(:dictionary)
            @object = build(:dictionary, dictionary.slice(*keys))
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', error_keys, 'duplicated_resource'
        end
      end

      context 'categoriesに同じ名前が含まれている場合' do
        before(:all) do
          category = build(:category)
          other_category = build(:category, {name: category.name})
          @object = build(:dictionary, {categories: [category, other_category]})
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', [:categories], 'include_same_value'
      end
    end
  end
end
