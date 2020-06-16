# coding: utf-8

require 'rails_helper'

describe Tag, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        tag_id: ['0' * 32],
        name: %w[test],
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      combinations = CommonHelper.generate_combinations(%i[tag_id name])

      combinations.each do |keys|
        context "#{keys.join(',')}が指定されていない場合" do
          expected_error = keys.map {|key| [key, 'absent_parameter'] }.to_h

          before(:all) do
            @object = build(:tag, keys.map {|key| [key, nil] }.to_h)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      invalid_attribute = {
        tag_id: ['0' * 33, 'g' * 32],
        name: ['0' * 11],
      }
      test_cases = CommonHelper.generate_test_case(invalid_attribute)
      test_cases.each do |test_case|
        context "#{test_case.keys.join(',')}が不正な場合" do
          expected_error = test_case.keys.map do |key|
            [key, 'invalid_parameter']
          end.to_h

          before(:all) do
            @object = build(:tag, test_case)
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
            tag = create(:tag)
            @object = build(:tag, tag.slice(*keys))
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      context '複合エラーの場合' do
        expected_error = {tag_id: 'absent_parameter', name: 'invalid_parameter'}

        before(:all) do
          @object = build(:tag, {tag_id: nil, name: '0' * 11})
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end
end
