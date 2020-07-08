# coding: utf-8

require 'rails_helper'

describe Payment, type: :model do
  describe '#validates' do
    describe '正常系' do
      valid_attribute = {payment_id: ['0' * 32]}

      CommonHelper.generate_test_case(valid_attribute).each do |attribute|
        context "#{attribute}を指定した場合" do
          before(:all) { @object = build(:payment, attribute) }

          it_behaves_like 'バリデーションエラーにならないこと'
        end
      end
    end

    describe '異常系' do
      context 'payment_idが指定されていない場合' do
        expected_error = {payment_id: 'absent_parameter'}

        before(:all) do
          @object = build(:payment, payment_id: nil)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end

      invalid_attribute = {
        payment_id: ['0' * 33, 'g' * 32, 1, [1], {id: 1}, true],
        categories: [
          {category_id: nil},
          {category_id: '0' * 33},
          {category_id: '1' * 32},
        ],
        tags: [
          {tag_id: nil},
          {tag_id: '0' * 33},
          {tag_id: '1' * 32},
        ],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
        context "#{attribute.keys.join(',')}が不正な場合" do
          expected_error = attribute.keys.map {|key| [key, 'invalid_parameter'] }.to_h

          include_context 'トランザクション作成'
          before(:all) do
            create(:category, {category_id: '1' * 32})
            create(:tag, {tag_id: '1' * 32})
            @object = build(:payment, attribute.except(:categories, :tags))
            @object.categories << build(:category, attribute[:categories] || {})
            @object.tags << build(:tag, attribute[:tags] || {})
            @object.validate
          end

          it_behaves_like 'エラーメッセージが正しいこと', expected_error
        end
      end

      context 'payment_idが重複している場合' do
        expected_error = {payment_id: 'duplicated_resource'}

        include_context 'トランザクション作成'
        before(:all) do
          payment = create(:payment)
          @object = build(:payment, {payment_id: payment.payment_id})
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end

      context '複合エラーの場合' do
        expected_error = {
          payment_id: 'absent_parameter',
          categories: 'invalid_parameter',
          tags: 'invalid_parameter',
        }

        before(:all) do
          attribute = {
            payment_id: nil,
            categories: [build(:category, category_id: nil)],
            tags: [build(:tag, tag_id: '0' * 33)],
          }
          @object = build(:payment, attribute)
          @object.validate
        end

        it_behaves_like 'エラーメッセージが正しいこと', expected_error
      end
    end
  end
end
