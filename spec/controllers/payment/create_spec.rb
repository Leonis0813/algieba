# coding: utf-8
require 'rails_helper'

describe PaymentsController, :type => :controller do
  shared_context '収支情報を登録する' do |params, app_auth_header = CommonHelper.app_auth_header|
    before(:all) do
      client.header('Authorization', app_auth_header)
      @res = client.post('/payments.json', params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: クライアントアプリを作成する'

  describe '正常系' do
    base_payment = PaymentHelper.test_payment[:income]

    [
      ['カテゴリリソースが既に存在している場合', base_payment],
      ['カテゴリリソースが存在しない場合', base_payment.merge(:category => 'not_exist')],
      ['複数のカテゴリを指定した場合', base_payment.merge(:category => 'algieba,other_category')],
    ].each do |description, payment|
      context description do
        after(:all) { Payment.where(payment.except(:id, :category)).destroy_all }
        include_context '収支情報を登録する', {:payments => payment}

        it_behaves_like 'ステータスコードが正しいこと', '201'
        it_behaves_like '収支情報リソースのキーが正しいこと'
        it_behaves_like 'カテゴリリソースのキーが正しいこと'

        (PaymentHelper.payment_params - ['category']).each do |attribute|
          it "#{attribute}の値が正しいこと" do
            expect(@pbody[attribute]).to eq payment[attribute.to_sym]
          end
        end

        it "カテゴリリソースの名前が#{payment[:category].split(',').sort}であること" do
          actual_categories = @pbody['categories'].map {|category| category['name'] }.sort
          expect(actual_categories).to eq payment[:category].split(',').sort
        end
      end
    end
  end

  describe '異常系' do
    context 'Authorizationヘッダーがない場合' do
      include_context '収支情報を登録する', {:payments => PaymentHelper.test_payment[:income]}, nil
      it_behaves_like '400エラーをチェックする', ['absent_header']
    end

    context 'Authorizationヘッダーが不正な場合' do
      include_context '収支情報を登録する', {:payments => PaymentHelper.test_payment[:income]}, 'invalid'
      it_behaves_like 'ステータスコードが正しいこと', '401'
    end

    payment_params = PaymentHelper.payment_params.map(&:to_sym)
    test_cases = [].tap do |tests|
      (payment_params.size - 1).times {|i| tests << payment_params.combination(i + 1).to_a }
    end.flatten(1)

    test_cases.each do |deleted_keys|
      context "#{deleted_keys.join(',')}がない場合" do
        selected_keys = payment_params - deleted_keys
        include_context '収支情報を登録する', {:payments => PaymentHelper.test_payment[:income].slice(*selected_keys)}
        it_behaves_like '400エラーをチェックする', deleted_keys.map {|key| "absent_param_#{key}" }
      end
    end

    [nil, {}, {:payments => nil}, {:payments => {}}].each do |params|
      context 'payments パラメーターがない場合' do
        include_context '収支情報を登録する', params
        it_behaves_like '400エラーをチェックする', ['absent_param_payments']
      end
    end

    [
      {:payment_type => 'invalid_type'},
      {:date => 'invalid_date'},
      {:price => 'invalid_price'},
      {:payment_type => 'invalid_type', :date => 'invalid_date', :price => 'invalid_price'},
    ].each do |invalid_param|
      context "#{invalid_param.keys.join(',')}が不正な場合" do
        include_context '収支情報を登録する', {:payments => PaymentHelper.test_payment[:expense].merge(invalid_param)}
        it_behaves_like '400エラーをチェックする', invalid_param.keys.map {|key| "invalid_param_#{key}" }
      end
    end
  end
end
