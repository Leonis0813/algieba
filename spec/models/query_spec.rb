# coding: utf-8

require 'rails_helper'

target = [Query, '#validates']

describe *target, type: :model do
  describe '正常系' do
    valid_params = {
      payment_type: 'income',
      date_before: ['1000-01-01', '1000/01/01', '01-01-1000', '01/01/1000', '10000101'],
      date_after: ['1000-01-01', '1000/01/01', '01-01-1000', '01/01/1000', '10000101'],
      price_upper: 100,
      price_lower: 100,
      page: 2,
      per_page: 50,
      sort: %w[id date price],
      order: %w[asc desc],
    }

    CommonHelper.generate_test_case(valid_params).each do |params|
      it "クエリに#{params.keys.join(',')}を指定した場合、エラーにならないこと" do
        query = Query.new(params)
        query.validate
        is_asserted_by { query.errors.empty? }

        params[:page] ||= 1
        params[:per_page] ||= 10
        params[:sort] ||= 'id'
        params[:order] ||= 'asc'
        is_asserted_by { query.attributes.slice(*params.keys) == params }
      end
    end
  end

  describe '異常系' do
    valid_params = {payment_type: 'income', date_before: '1000-01-01'}
    invalid_params = {
      payment_type: 'invalid_type',
      date_before: ['invalid_date', '1000-13-01', '1000-01-00', '1000-13-00'],
      date_after: ['invalid_date', '1000-13-01', '1000-01-00', '1000-13-00'],
      price_upper: ['invalid_price', 1.0, -1],
      price_lower: ['invalid_price', 1.0, -1],
      page: ['invalid_page', 1.0, -1],
      per_page: ['invalid_per_page', 1.0, -1],
      sort: ['invalid', 1],
      order: ['invalid', 1],
    }

    CommonHelper.generate_test_case(invalid_params).each do |params|
      it "クエリに#{params.keys.join(',')}を指定した場合、エラーになること" do
        query = Query.new(params)
        query.validate
        is_asserted_by { not query.errors.empty? }

        expected_messages = params.map {|key, _| [key, ['invalid']] }.to_h
        is_asserted_by { query.errors.messages == expected_messages }
      end
    end

    invalid_period = {
      date_before: ['1000-01-01', '1000/01/01', '01-01-1000', '01/01/1000', '10000101'],
      date_after: ['1000-01-02', '1000/01/02', '02-01-1000', '02/01/1000', '10000102'],
    }

    test_cases = CommonHelper.generate_test_case(invalid_period).select do |test_case|
      test_case.keys == %i[date_before date_after]
    end

    test_cases.each do |params|
      it '期間が不正な場合、エラーになること' do
        query = Query.new(params)
        query.validate
        is_asserted_by { not query.errors.empty? }

        expected_messages = params.map {|key, _| [key, ['invalid']] }.to_h
        is_asserted_by { query.errors.messages == expected_messages }
      end
    end
  end
end
