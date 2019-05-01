# coding: utf-8
require 'rails_helper'

describe '収支情報を管理する', type: :request do
  category = 'algieba'
  valid_payment = {
    payment_type: 'expense',
    date: '1000-01-01',
    content: 'システムテスト用データ',
    category: category,
    price: 100,
  }
  invalid_payment = {
    payment_type: 'expense',
    date: 'invalid_date',
    category: category,
    price: 100,
  }

  shared_context 'GET /api/payments/[:id]' do
    before(:all) do
      header = {'Authorization' => app_auth_header}
      @res = http_client.get("#{base_url}/api/payments/#{@id}", nil, header)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  shared_context 'GET /api/categories' do |param = {}|
    before(:all) do
      header = {'Authorization' => app_auth_header}
      @res = http_client.get("#{base_url}/api/categories", param, header)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  describe 'カテゴリを検索する' do
    include_context 'GET /api/categories'
    it_behaves_like 'ステータスコードが正しいこと', '200'
    it_behaves_like 'レスポンスボディのキーが正しいこと', CategoryHelper.response_keys

    describe '収支情報を登録する' do
      include_context 'POST /api/payments', invalid_payment
      it_behaves_like '400エラーをチェックする', ['absent_param_content']

      describe '収支情報を登録する' do
        include_context 'POST /api/payments', valid_payment
        before(:all) { @created_payment = @pbody }
        it_behaves_like 'ステータスコードが正しいこと', '201'
        it_behaves_like 'レスポンスボディのキーが正しいこと', PaymentHelper.response_keys

        describe 'カテゴリを検索する' do
          include_context 'GET /api/categories', keyword: category
          it_behaves_like 'ステータスコードが正しいこと', '200'
          it_behaves_like 'レスポンスボディのキーが正しいこと',
                          CategoryHelper.response_keys

          it 'カテゴリにalgiebaが含まれていること' do
            is_asserted_by { @pbody.map {|body| body['name'] }.include?(category) }
          end

          describe '収支情報を取得する' do
            before(:all) { @id = @created_payment['id'] }
            include_context 'GET /api/payments/[:id]'
            it_behaves_like 'ステータスコードが正しいこと', '200'
            it_behaves_like 'レスポンスボディのキーが正しいこと',
                            PaymentHelper.response_keys

            describe '収支情報を更新する' do
              before(:all) do
                url = "#{base_url}/api/payments/#{@created_payment['id']}"
                body = {category: 'other'}.to_json
                header = {'Authorization' => app_auth_header}.merge(content_type_json)
                @res = http_client.put(url, body, header)
                @pbody = JSON.parse(@res.body) rescue nil
              end

              it_behaves_like 'ステータスコードが正しいこと', '200'
              it_behaves_like 'レスポンスボディのキーが正しいこと',
                              PaymentHelper.response_keys

              it '収支情報が更新されていること' do
                is_asserted_by { @pbody['categories'].first['name'] == 'other' }
              end

              describe 'カテゴリを検索する' do
                include_context 'GET /api/categories', keyword: 'other'
                it_behaves_like 'ステータスコードが正しいこと', '200'
                it_behaves_like 'レスポンスボディのキーが正しいこと',
                                CategoryHelper.response_keys

                it 'カテゴリにotherが含まれていること' do
                  is_asserted_by { @pbody.map {|body| body['name'] }.include?('other') }
                end

                describe '収支情報を検索する' do
                  params = {
                    payment_type: 'income',
                    page: 1,
                    per_page: 100,
                    sort: 'price',
                    order: 'desc',
                  }
                  include_context 'GET /api/payments', params
                  it_behaves_like 'ステータスコードが正しいこと', '200'
                  it_behaves_like 'レスポンスボディのキーが正しいこと',
                                  PaymentHelper.response_keys

                  describe '収支情報を削除する' do
                    before(:all) do
                      url = "#{base_url}/api/payments/#{@created_payment['id']}"
                      header = {'Authorization' => app_auth_header}
                      @res = http_client.delete(url, nil, header)
                      @pbody = JSON.parse(@res.body) rescue nil
                    end

                    it_behaves_like 'ステータスコードが正しいこと', '204'

                    describe '収支情報を取得する' do
                      before(:all) { @id = @created_payment['id'] }
                      include_context 'GET /api/payments/[:id]'
                      it_behaves_like 'ステータスコードが正しいこと', '404'
                    end

                    describe 'カテゴリを検索する' do
                      include_context 'GET /api/categories'
                      it_behaves_like 'ステータスコードが正しいこと', '200'
                      it_behaves_like 'レスポンスボディのキーが正しいこと',
                                      CategoryHelper.response_keys

                      %w[ algieba other ].each do |category|
                        it "カテゴリに#{category}が含まれていること" do
                          is_asserted_by do
                            @pbody.map {|body| body['name'] }.include?(category)
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
