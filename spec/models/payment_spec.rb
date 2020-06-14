# coding: utf-8

require 'rails_helper'

describe Payment, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {
        payment_id: ['0' * 32],
        payment_type: %w[income expense],
        date: %w[1000-01-01 1000/01/01 01-01-1000 01/01/1000 10000101],
        content: 'モジュールテスト用データ',
        price: 0,
      }

      it_behaves_like '正常な値を指定した場合のテスト', valid_attribute
    end

    describe '異常系' do
      attribute_names = %i[payment_id payment_type content price categories]
      blank_value = {categories: []}

      CommonHelper.generate_combinations(attribute_names).each do |keys|
        context "#{keys.join(',')}が指定されていない場合" do
          before(:all) do
            @object = build(:payment, keys.map {|key| [key, blank_value[key]] }.to_h)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', keys, 'absent_parameter'
        end
      end

      invalid_attribute = {
        payment_id: ['0' * 33, 'g' * 32],
        payment_type: 'invalid',
        date: %w[invalid 1000-13-01 1000-01-00 1000-13-00],
        price: [-1],
      }
      test_cases = CommonHelper.generate_test_case(invalid_attribute)
      test_cases.each do |test_case|
        context "#{test_case.keys.join(',')}が不正な場合" do
          before(:all) do
            @object = build(:payment, test_case)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', test_case.keys, 'invalid_parameter'
        end
      end

      context 'payment_idが重複している場合' do
        include_context 'トランザクション作成'
        before(:all) do
          payment = create(:payment)
          @object = build(:payment, {payment_id: payment.payment_id})
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', [:payment_id], 'duplicated_resource'
      end

      [[:categories], [:tags], [:categories, :tags]].each do |keys|
        context "#{keys.join(',')}に同じ値が含まれている場合" do
          before(:all) do
            attributes = {}
            keys.each do |key|
              object = build(key.to_s.singularize.to_sym)
              other_object = build(key.to_s.singularize.to_sym, {name: object.name})
              attributes[key] = [object, other_object]
            end

            @object = build(:payment, attributes)
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', keys, 'include_same_value'
        end
      end
    end
  end
end
