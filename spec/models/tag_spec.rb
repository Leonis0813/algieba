# coding: utf-8

require 'rails_helper'

describe Tag, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {tag_id: ['0' * 32]}

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:tag, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      context 'tag_idが指定されていない場合' do
        expected_error = {tag_id: 'absent_parameter'}

        before(:all) do
          @object = build(:tag, tag_id: nil)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end

      invalid_attribute = {
        tag_id: ['0' * 33, 'g' * 32, 1, [1], {id: 1}, true],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          before(:all) do
            @object = build(:tag, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      CommonHelper.generate_combinations(%i[tag_id name]).each do |keys|
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
        expected_error = {tag_id: 'invalid_parameter', name: 'duplicated_resource'}

        include_context 'トランザクション作成'
        before(:all) do
          tag = create(:tag)
          @object = build(:tag, {tag_id: '0' * 33, name: tag.name})
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end
end
