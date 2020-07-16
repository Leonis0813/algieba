# coding: utf-8

require 'rails_helper'

describe PaymentQuery, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        sort: %w[payment_id date price],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:payment_query, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      invalid_attribute = {
        sort: ['invalid', 1, ['date'], {sort: 'date'}, true],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

        context "#{attribute.keys.join(',')}が不正な場合" do
          before(:all) do
            @object = build(:payment_query, attribute)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      context '期間が不正な場合' do
        before(:all) do
          attribute = {date_before: '1000-01-01', date_after: '1000-01-02'}
          @object = build(:payment_query, attribute)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', {
          date_before: 'invalid_parameter',
          date_after: 'invalid_parameter',
        }
      end
    end
  end
end
