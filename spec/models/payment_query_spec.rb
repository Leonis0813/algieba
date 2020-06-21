# coding: utf-8

require 'rails_helper'

target = [PaymentQuery, '#validates']

describe(*target, type: :model) do
  describe '正常系' do
    valid_attribute = {
      payment_type: ['income', 'expense', nil],
      date_before: ['1000-01-01', nil],
      date_after: ['1000-01-01', nil],
      content_equal: ['test', nil],
      content_include: ['test', nil],
      category: ['test', nil],
      tag: ['test', nil],
      price_upper: [0, nil],
      price_lower: [0, nil],
      sort: %w[payment_id date price],
    }

    it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
  end

  describe '異常系' do
    invalid_attribute = {
      payment_type: ['invalid', 1, ['income'], {payment_type: 'income'}, true],
      date_before: %w[invalid 1000-13-01 1000-01-00 1000-13-00],
      date_after: %w[invalid 1000-13-01 1000-01-00 1000-13-00],
      price_upper: [-1],
      price_lower: [-1],
      sort: %w[invalid],
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
