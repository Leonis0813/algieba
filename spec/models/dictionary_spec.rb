# coding: utf-8

require 'rails_helper'

describe Dictionary, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {dictionary_id: ['0' * 32]}

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:dictionary, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      context 'dictionary_idが指定されていない場合' do
        expected_error = {dictionary_id: 'absent_parameter'}

        before(:all) do
          @object = build(:dictionary, dictionary_id: nil)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end

      invalid_attribute = {
        dictionary_id: ['0' * 33, 'g' * 32, 1, [1], {id: 1}, true],
        categories: [
          {category_id: nil},
          {category_id: '0' * 33},
          {category_id: '1' * 32},
        ],
      }
      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          include_context 'トランザクション作成'
          before(:all) do
            create(:category, {category_id: '1' * 32})
            @object = build(:dictionary, attribute.except(:categories))
            @object.categories << build(:category, attribute[:categories] || {})
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      [
        %i[dictionary_id],
        %i[phrase condition],
        %i[dictionary_id phrase condition],
      ].each do |keys|
        error_keys = keys - [:condition]

        context "#{keys.join(',')}が重複している場合" do
          expected_error = error_keys.map {|key| [key, 'duplicated_resource'] }.to_h

          include_context 'トランザクション作成'
          before(:all) do
            dictionary = create(:dictionary)
            @object = build(:dictionary, dictionary.slice(*keys))
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      context '複合エラーの場合' do
        expected_error = {
          dictionary_id: 'absent_parameter',
          phrase: 'duplicated_resource',
          categories: 'invalid_parameter',
        }

        include_context 'トランザクション作成'
        before(:all) do
          dictionary = create(:dictionary)
          attribute = {
            dictionary_id: nil,
            phrase: dictionary.phrase,
            condition: dictionary.condition,
            categories: [build(:category, category_id: nil)],
          }
          @object = build(:dictionary, attribute)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end
end
