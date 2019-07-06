# coding: utf-8

require 'rails_helper'

describe Dictionary, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attributes = {
        phrase: 'phrase',
        condition: %w[equal include],
      }

      CommonHelper.generate_test_case(valid_attributes).each do |attributes|
        it "#{attributes}を指定した場合、エラーにならないこと" do
          dictionary = Dictionary.new(attributes)
          dictionary.validate
          is_asserted_by { dictionary.errors.empty? }
        end
      end
    end

    describe '異常系' do
      invalid_attributes = {
        phrase: [nil],
        condition: ['invalid', 0, 1.0, nil],
      }

      CommonHelper.generate_test_case(invalid_attributes).each do |attributes|
        it "#{attributes}を指定した場合、invalidエラーになること" do
          dictionary = Dictionary.new(attributes)
          dictionary.validate
          messages = {phrase: ['invalid'], condition: ['invalid']}
          is_asserted_by { dictionary.errors.messages == messages }
        end
      end
    end
  end
end
