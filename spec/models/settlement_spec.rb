# coding: utf-8

require 'rails_helper'

describe Settlement, type: :model do
  describe '#calculate' do
    context '収支情報がない場合' do
      before(:all) { @settlements = build(:settlement).calculate }

      it '空配列が返ること' do
        is_asserted_by { @settlements == [] }
      end
    end

    context '収支情報がある場合' do
      include_context 'トランザクション作成'
      before(:all) do
        create(:payment)
        create(:payment, payment_type: 'expense', date: '1000-02-02')
        create(:payment, date: '1000-01-03', price: 100)
        create(:payment, categories: [build(:category, name: 'other')])
      end

      [
        ['income', [{category: 'test', price: 1100}, {category: 'other', price: 1000}]],
        ['expense', [{category: 'test', price: 1000}]],
      ].each do |payment_type, expected_settlements|
        context "aggregation_typeがcategoryで#{payment_type}を指定する場合" do
          before(:all) do
            @settlements = build(:settlement, payment_type: payment_type).calculate
          end

          it '計算結果が正しいこと' do
            is_asserted_by { @settlements = expected_settlements }
          end
        end
      end

      [
        ['yearly', [{date: '1000', price: 1100}]],
        ['monthly', [{date: '1000-01', price: 1100}]],
        [
          'daily',
          [
            {date: '1000-01-01', price: 2000},
            {date: '1000-01-02', price: -1000},
            {date: '1000-01-03', price: 100},
          ],
        ],
      ].each do |interval, expected_settlements|
        context "aggregation_typeがperiodで#{interval}を指定する場合" do
          before(:all) do
            attribute = {aggregation_type: 'period', interval: interval}
            @settlements = build(:settlement, attribute).calculate
          end

          it '計算結果が正しいこと' do
            is_asserted_by { @settlements = expected_settlements }
          end
        end
      end
    end
  end
end
