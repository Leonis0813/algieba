# coding: utf-8

require 'rails_helper'

describe '収支情報を管理する', type: :request do
  test_category = 'algieba'
  valid_payment = {
    payment_type: 'expense',
    date: '1000-01-01',
    content: 'システムテスト用データ',
    categories: [test_category],
    price: 100,
  }
  invalid_payment = {
    payment_type: 'expense',
    date: 'invalid_date',
    categories: [test_category],
    price: 100,
  }

  shared_context 'GET /api/payments/[:payment_id]' do
    before(:all) do
      url = "#{base_url}/api/payments/#{@payment_id}"
      res = http_client.get(url, nil, app_auth_header)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  shared_context 'GET /api/categories' do |param = {}|
    before(:all) do
      res = http_client.get("#{base_url}/api/categories", param, app_auth_header)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  shared_examples 'カテゴリ検索時のレスポンスが正しいこと' do
    it_is_asserted_by { @response_status == 200 }

    it_is_asserted_by { @response_body.keys.sort == %w[categories] }

    it do
      @response_body['categories'].each do |category|
        is_asserted_by { category.keys.sort == CategoryHelper.response_keys }
      end
    end
  end

  shared_examples '収支情報のレスポンスが正しいこと' do |status: 200|
    it_is_asserted_by { @response_status == status }

    it_is_asserted_by { @response_body.keys.sort == PaymentHelper.response_keys }

    it do
      @response_body['categories'].each do |category|
        is_asserted_by { category.keys.sort == CategoryHelper.response_keys }
      end
    end

    it do
      @response_body['tags'].each do |tag|
        is_asserted_by { tag.keys.sort == TagHelper.response_keys }
      end
    end
  end

  describe 'カテゴリを検索する' do
    include_context 'GET /api/categories'
    it_behaves_like 'カテゴリ検索時のレスポンスが正しいこと'

    describe '収支情報を登録する' do
      errors = [{'error_code' => 'absent_param_content'}]
      include_context 'POST /api/payments', invalid_payment
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}

      describe '収支情報を登録する' do
        include_context 'POST /api/payments', valid_payment
        before(:all) { @created_payment = @response_body }
        it_behaves_like '収支情報のレスポンスが正しいこと', status: 201

        describe 'カテゴリを検索する' do
          include_context 'GET /api/categories', keyword: test_category
          it_behaves_like 'カテゴリ検索時のレスポンスが正しいこと'

          it "カテゴリに#{test_category}が含まれていること" do
            is_asserted_by do
              @response_body['categories'].any? do |category|
                category['name'] == test_category
              end
            end
          end

          describe '収支情報を取得する' do
            before(:all) { @payment_id = @created_payment['payment_id'] }
            include_context 'GET /api/payments/[:payment_id]'
            it_behaves_like '収支情報のレスポンスが正しいこと'

            describe '収支情報を更新する' do
              before(:all) do
                url = "#{base_url}/api/payments/#{@payment_id}"
                body = {categories: ['other']}.to_json
                header = app_auth_header.merge(content_type_json)
                res = http_client.put(url, body, header)
                @response_status = res.status
                @response_body = JSON.parse(res.body) rescue res.body
              end

              it_behaves_like '収支情報のレスポンスが正しいこと'

              it '収支情報が更新されていること' do
                is_asserted_by { @response_body['categories'].first['name'] == 'other' }
              end

              describe 'カテゴリを検索する' do
                include_context 'GET /api/categories', keyword: 'other'
                it_behaves_like 'カテゴリ検索時のレスポンスが正しいこと'

                it 'カテゴリにotherが含まれていること' do
                  is_asserted_by do
                    @response_body['categories'].any? do |category|
                      category['name'] == 'other'
                    end
                  end
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
                  it_behaves_like '収支検索時のレスポンスが正しいこと'

                  describe '収支情報を削除する' do
                    before(:all) do
                      url = "#{base_url}/api/payments/#{@payment_id}"
                      res = http_client.delete(url, nil, app_auth_header)
                      @response_status = res.status
                      @response_body = JSON.parse(res.body) rescue res.body
                    end

                    it_behaves_like 'レスポンスが正しいこと', status: 204, body: ''

                    describe '収支情報を取得する' do
                      include_context 'GET /api/payments/[:payment_id]'
                      it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
                    end

                    describe 'カテゴリを検索する' do
                      include_context 'GET /api/categories'
                      it_behaves_like 'カテゴリ検索時のレスポンスが正しいこと'

                      %w[algieba other].each do |category_name|
                        it "カテゴリに#{category_name}が含まれていること" do
                          is_asserted_by do
                            @response_body['categories'].any? do |category|
                              category['name'] == category_name
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
end
