# coding: utf-8
require 'rails_helper'

describe '収支情報を管理する', :type => :request do
  category = 'algieba'
  valid_payment = {:payment_type => 'expense', :date => '1000-01-01', :content => 'システムテスト用データ', :category => category, :price => 100}
  invalid_payment = {:payment_type => 'expense', :date => 'invalid_date', :category => category, :price => 100}

  shared_context 'GET /payments/[:id]' do
    before(:all) do
      header = {'Authorization' => app_auth_header}
      @res = http_client.get("#{base_url}/payments/#{@id}", nil, header)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  shared_context 'GET /categories' do |param = {}|
    before(:all) do
      header = {'Authorization' => app_auth_header}
      @res = http_client.get("#{base_url}/categories", param, header)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  describe 'カテゴリを検索する' do
    include_context 'GET /categories'
    it_behaves_like 'ステータスコードが正しいこと', '200'
    it_behaves_like 'レスポンスボディのキーが正しいこと', CategoryHelper.response_keys

    describe '収支情報を登録する' do
      include_context 'POST /payments', invalid_payment
      it_behaves_like '400エラーをチェックする', ['absent_param_content']

      describe '収支情報を登録する' do
        include_context 'POST /payments', valid_payment
        before(:all) { @created_payment = @pbody }
        it_behaves_like 'ステータスコードが正しいこと', '201'
        it_behaves_like 'レスポンスボディのキーが正しいこと', PaymentHelper.response_keys

        describe 'カテゴリを検索する' do
          include_context 'GET /categories', {:keyword => category}
          it_behaves_like 'ステータスコードが正しいこと', '200'
          it_behaves_like 'レスポンスボディのキーが正しいこと', CategoryHelper.response_keys

          it 'カテゴリにalgiebaが含まれていること' do
            expect(@pbody.map {|body| body['name'] }).to include category
          end

          describe '収支情報を取得する' do
            before(:all) { @id = @created_payment['id'] }
            include_context 'GET /payments/[:id]'
            it_behaves_like 'ステータスコードが正しいこと', '200'
            it_behaves_like 'レスポンスボディのキーが正しいこと', PaymentHelper.response_keys

            describe '収支情報を更新する' do
              before(:all) do
                header = {'Authorization' => app_auth_header}.merge(content_type_json)
                @res = http_client.put("#{base_url}/payments/#{@created_payment['id']}", {:category => 'other'}.to_json, header)
                @pbody = JSON.parse(@res.body) rescue nil
              end

              it_behaves_like 'ステータスコードが正しいこと', '200'
              it_behaves_like 'レスポンスボディのキーが正しいこと', PaymentHelper.response_keys

              it '収支情報が更新されていること' do
                expect(@pbody['categories'].first['name']).to eq 'other'
              end

              describe 'カテゴリを検索する' do
                include_context 'GET /categories', {:keyword => 'other'}
                it_behaves_like 'ステータスコードが正しいこと', '200'
                it_behaves_like 'レスポンスボディのキーが正しいこと', CategoryHelper.response_keys

                it 'カテゴリにotherが含まれていること' do
                  expect(@pbody.map {|body| body['name'] }).to include 'other'
                end

                describe '収支情報を検索する' do
                  include_context 'GET /payments', {:payment_type => 'income'}
                  it_behaves_like 'ステータスコードが正しいこと', '200'
                  it_behaves_like 'レスポンスボディのキーが正しいこと', PaymentHelper.response_keys

                  describe '収支情報を削除する' do
                    before(:all) do
                      header = {'Authorization' => app_auth_header}
                      @res = http_client.delete("#{base_url}/payments/#{@created_payment['id']}", nil, header)
                      @pbody = JSON.parse(@res.body) rescue nil
                    end

                    it_behaves_like 'ステータスコードが正しいこと', '204'

                    describe '収支情報を取得する' do
                      before(:all) { @id = @created_payment['id'] }
                      include_context 'GET /payments/[:id]'
                      it_behaves_like 'ステータスコードが正しいこと', '404'
                    end

                    describe 'カテゴリを検索する' do
                      include_context 'GET /categories'
                      it_behaves_like 'ステータスコードが正しいこと', '200'
                      it_behaves_like 'レスポンスボディのキーが正しいこと', CategoryHelper.response_keys

                      %w[ algieba other ].each do |category|
                        it "カテゴリに#{category}が含まれていること" do
                          expect(@pbody.map {|body| body['name'] }).to include category
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
