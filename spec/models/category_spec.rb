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
          expected_error = keys.map {|key| [key, 'absent_parameter'] }.to_h

          before(:all) do
            @object = build(:category, keys.map {|key| [key, nil] }.to_h)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      invalid_attribute = {
        category_id: ['0' * 33, 'g' * 32, 1, [1], {id: 1}, true],
        name: [1, [1], {id: 1}, true],
        description: [1, [1], {id: 1}, true],
      }
      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

        context "#{attribute.keys.join(',')}が不正な場合" do
          before(:all) do
            @object = build(:category, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      combinations.each do |keys|
        context "#{keys.join(',')}が重複している場合" do
          expected_error = keys.map {|key| [key, 'duplicated_resource'] }.to_h

          include_context 'トランザクション作成'
          before(:all) do
            category = create(:category)
            @object = build(:category, category.slice(*keys))
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      context '複合エラーの場合' do
        expected_error = {category_id: 'absent_parameter', name: 'duplicated_resource'}

        include_context 'トランザクション作成'
        before(:all) do
          category = create(:category)
          @object = build(:category, {category_id: nil, name: category.name})
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end
end
