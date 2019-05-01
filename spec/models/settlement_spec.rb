# coding: utf-8
require 'rails_helper'

describe Settlement, type: :model do
  describe '#validates' do
    shared_context 'Settlementオブジェクトを検証する' do |params|
      before(:all) do
        @settlement = Settlement.new(params)
        @settlement.validate
      end
    end

    shared_examples '検証結果が正しいこと' do |result|
      it_is_asserted_by { @settlement.errors.empty? == result }
    end

    describe '正常系' do
      %w[ yearly monthly daily ].each do |interval|
        context "クエリに#{interval}を指定した場合" do
          include_context 'Settlementオブジェクトを検証する', {interval: interval}
          it_behaves_like '検証結果が正しいこと', true
        end
      end
    end

    describe '異常系' do
      [[nil, 'absent'], %w[ invalid_interval invalid ]].each do |interval, message|
        context "クエリに#{interval || 'nil'}を指定した場合" do
          include_context 'Settlementオブジェクトを検証する', {interval: interval}
          it_behaves_like '検証結果が正しいこと', false

          it 'エラーメッセージが正しいこと' do
            is_asserted_by { @settlement.errors.messages == {interval: [message] } }
          end
        end
      end
    end
  end
end
