# coding: utf-8

require 'rails_helper'

describe Query, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        page: %w[2],
        per_page: %w[50],
        order: %w[asc desc],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:query, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      invalid_attribute = {
        page: ['0', 1, [1], {page: 1}, true],
        per_page: ['0', 1, [1], {per_page: 1}, true],
        order: ['invalid', 1, ['asc'], {order: 'asc'}, true],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          before(:all) do
            @object = build(:query, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end
    end
  end
end
