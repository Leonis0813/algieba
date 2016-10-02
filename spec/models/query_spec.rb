# coding: utf-8
require 'rails_helper'

describe Query, :type => :model do
  describe '#validates' do
    shared_context 'Queryオブジェクトを検証する' do |params|
      before(:all) do
        @query = Query.new(params)
        @query.validate
      end
    end

    shared_examples '検証結果が正しいこと' do |result|
      it { expect(@query.errors.empty?).to be result }
    end

    shared_examples 'エラーメッセージが正しいこと' do |expected_messages|
      it { expect(@query.errors.messages).to eq expected_messages }
    end

    describe '正常系' do
      valid_params = {
        :account_type => 'income',
        :date_before => ['1000-01-01', '1000/01/01', '01-01-1000', '01/01/1000', '10000101'],
        :date_after => ['1000-01-01', '1000/01/01', '01-01-1000', '01/01/1000', '10000101'],
        :content_equal => 'content',
        :content_include => 'content',
        :category => 'category',
        :price_upper => 100,
        :price_lower => 100,
      }
      CommonHelper.generate_test_case(valid_params).each do |params|
        context "クエリに#{params.keys.join(',')}を指定した場合" do
          include_context 'Queryオブジェクトを検証する', params
          it_behaves_like '検証結果が正しいこと', true
        end
      end
    end

    describe '異常系' do
      valid_params = {:account_type => 'income', :date_before => '1000-01-01'}
      invalid_params = {
        :account_type => 'invalid_type',
        :date_before => ['invalid_date', '1000-13-01', '1000-01-00', '1000-13-00'],
        :date_after => ['invalid_date', '1000-13-01', '1000-01-00', '1000-13-00'],
        :price_upper => ['invalid_price', 1.0, -1],
        :price_lower => ['invalid_price', 1.0, -1],
      }

      CommonHelper.generate_test_case(invalid_params).each do |params|
        context "クエリに#{params.keys.join(',')}を指定した場合" do
          include_context 'Queryオブジェクトを検証する', valid_params.merge(params)

          it_behaves_like '検証結果が正しいこと', false
          it_behaves_like 'エラーメッセージが正しいこと', params.map {|key, _| [key, ['invalid']] }.to_h
        end
      end

      invalid_period = {
        :date_before => ['1000-01-01', '1000/01/01', '01-01-1000', '01/01/1000', '10000101'],
        :date_after => ['1000-01-02', '1000/01/02', '02-01-1000', '02/01/1000', '10000102'],
      }

      test_cases = CommonHelper.generate_test_case(invalid_period).select {|test_case| test_case.keys == %i[ date_before date_after ] }

      test_cases.each do |params|
        context '期間が不正な場合' do
          include_context 'Queryオブジェクトを検証する', valid_params.merge(params)

          it_behaves_like '検証結果が正しいこと', false
          it_behaves_like 'エラーメッセージが正しいこと', params.map {|key, _| [key, ['invalid']] }.to_h
        end
      end

      test_cases = CommonHelper.generate_test_case(invalid_params.merge(invalid_period)).select do |test_case|
        test_case.include?(:date_before) and test_case.include?(:date_after)
      end

      test_cases.each do |params|
        context '期間が不正な場合' do
          include_context 'Queryオブジェクトを検証する', params

          it_behaves_like '検証結果が正しいこと', false
          it_behaves_like 'エラーメッセージが正しいこと', params.map {|key, _| [key, ['invalid']] }.to_h
        end
      end
    end
  end
end
