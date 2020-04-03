# coding: utf-8

require 'rails_helper'

target = [PaymentQuery, '#validates']

describe(*target, type: :model) do
  describe '正常系' do
    valid_attribute = {
      payment_type: %w[income expense],
      date_before: %w[1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101],
      date_after: %w[1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101],
      price_upper: 0,
      price_lower: 0,
      sort: %w[payment_id date price],
    }

    it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
  end

  describe '異常系' do
    invalid_attribute = {
      payment_type: 'invalid',
      date_before: %w[invalid 1000-13-01 1000-01-00 1000-13-00],
      date_after: %w[invalid 1000-13-01 1000-01-00 1000-13-00],
      price_upper: [-1],
      price_lower: [-1],
      sort: %w[invalid],
    }

    it_behaves_like '不正な値を指定した場合のテスト', invalid_attribute

    invalid_period = {
      date_before: %w[1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101],
      date_after: %w[1000-01-02 1000/01/02 02-01-1000 02/01/1000 10000102],
    }

    CommonHelper.generate_test_case(invalid_period).each do |params|
      it '期間が不正な場合、エラーになること' do
        query = PaymentQuery.new(params)
        query.validate
        is_asserted_by { not query.errors.empty? }

        expected_messages = params.map {|key, _| [key, ['invalid']] }.to_h
        is_asserted_by { query.errors.messages == expected_messages }
      end
    end
  end
end
