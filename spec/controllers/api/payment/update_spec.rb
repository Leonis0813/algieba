# coding: utf-8
require 'rails_helper'

describe PaymentsController, :type => :controller do
  shared_context '収支情報を更新する' do |id, params = {}, app_auth_header = CommonHelper.app_auth_header|
    before(:all) do
      client.header('Authorization', app_auth_header)
      @res = client.put("/api/payments/#{id}", params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: クライアントアプリを作成する'
  after(:all) { Category.destroy_all }

  describe '正常系' do
    base_payment = PaymentHelper.test_payment[:income]

    [
      {:payment_type => 'expense'},
      {:date => '1000-01-02'},
      {:content => '更新後データ'},
      {:category => 'updated'},
      {:price => 1},
      {
        :payment_type => 'expense',
        :date => '1000-01-02',
        :content => '更新後データ',
        :category => 'updated',
        :price => 1,
      },
      {},
    ].each do |params|
      description = params.empty? ? '更新しない場合' : "#{params.keys.join(',')}を更新する場合"

      context description do
        include_context '事前準備: 収支情報を登録する'
        include_context '収支情報を更新する', base_payment[:id], params
        it_behaves_like 'ステータスコードが正しいこと', '200'
        it_behaves_like '収支情報リソースのキーが正しいこと'
        it_behaves_like 'カテゴリリソースのキーが正しいこと'
        it_behaves_like '収支情報リソースの属性値が正しいこと', base_payment.merge(params).except(:id, :category)
        it_behaves_like 'カテゴリリソースの属性値が正しいこと', [base_payment.merge(params)[:category].split(',').sort]
      end
    end

    [
      ['カテゴリリソースが既に存在している場合', :category => 'algieba'],
      ['カテゴリリソースが存在しない場合', :category => 'not_exist'],
      ['複数のカテゴリを指定した場合', :category => 'algieba,other_category'],
    ].each do |description, params|
      context description do
        after(:all) { Payment.where(base_payment.except(:id, :category)).destroy_all }
        include_context '事前準備: 収支情報を登録する'
        include_context '収支情報を更新する', base_payment[:id], params

        it_behaves_like 'ステータスコードが正しいこと', '200'

        it 'レスポンスボディのキーが正しいこと' do
          is_asserted_by { @pbody.keys == response_keys }
        end

        it 'カテゴリリソースのキーが正しいこと' do
          @pbody['categories'].each do |category|
            is_asserted_by { category.keys == %w[ id name description ] }
          end
        end

        (PaymentHelper.payment_params - ['category']).each do |attribute|
          it "#{attribute}の値が正しいこと" do
            is_asserted_by { @pbody[attribute] == base_payment[attribute.to_sym] }
          end
        end

        it "カテゴリリソースの名前が#{base_payment[:category].split(',').sort}であること" do
          actual_categories = @pbody['categories'].map {|category| category['name'] }.sort
          is_asserted_by { actual_categories == base_payment.merge(params)[:category].split(',').sort }
        end
      end
    end
  end

  describe '異常系' do
    context 'Authorizationヘッダーがない場合' do
      include_context '収支情報を更新する', PaymentHelper.test_payment[:income][:id], {}, nil
      it_behaves_like '400エラーをチェックする', ['absent_header']
    end

    context 'Authorizationヘッダーが不正な場合' do
      include_context '収支情報を更新する', PaymentHelper.test_payment[:income][:id], {}, 'invalid'
      it_behaves_like 'ステータスコードが正しいこと', '401'
    end

    [
      {:payment_type => 'invalid_type'},
      {:date => 'invalid_date'},
      {:price => 'invalid_price'},
      {:payment_type => 'invalid_type', :date => 'invalid_date', :price => 'invalid_price'},
    ].each do |params|
      context "#{params.keys.join(',')}が不正な場合" do
        include_context '事前準備: 収支情報を登録する'
        include_context '収支情報を更新する', PaymentHelper.test_payment[:income][:id], params
        it_behaves_like '400エラーをチェックする', params.map {|key, _| "invalid_param_#{key}" }
      end
    end

    context '存在しないidを指定した場合' do
      include_context '収支情報を更新する', 100, {:payment_type => 'expense'}
      it_behaves_like 'ステータスコードが正しいこと', '404'
    end
  end
end