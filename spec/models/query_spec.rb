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
      valid_params = {:account_type => 'income'}
      invalid_params = {
        :account_type => 'invalid_type',
        :date_before => ['invalid_date', '1000-13-01', '1000-01-00', '1000-13-00'],
        :date_after => ['invalid_date', '1000-13-01', '1000-01-00', '1000-13-00'],
        :price_upper => ['invalid_price', 1.0, -1],
        :price_lower => ['invalid_price', 1.0, -1],
      }

      test_cases = CommonHelper.generate_test_case(invalid_params) << {:date_before => '1000-01-01', :date_after => '1000-01-02'}
      test_cases.each do |params|
        context "クエリに#{params.keys.join(',')}を指定した場合" do
          include_context 'Queryオブジェクトを検証する', valid_params.merge(params)

          it_behaves_like '検証結果が正しいこと', false

          it 'エラーメッセージが正しいこと' do
            expect(@query.errors.messages).to eq params.map {|key, _| [key, ['invalid']] }.to_h
          end
        end
      end
    end
  end
end
