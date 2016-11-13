# coding: utf-8
require 'rails_helper'

describe '家計簿を管理する', :type => :request do
  valid_account = {:account_type => 'expense', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'algieba', :price => 100}
  invalid_account = {:account_type => 'expense', :date => 'invalid_date', :category => 'algieba', :price => 100}

  shared_context 'GET /accounts/[:id]' do
    before(:all) do
      header = {'Authorization' => app_auth_header}
      @res = http_client.get("#{base_url}/accounts/#{@id}", nil, header)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  describe '家計簿を登録する' do
    include_context 'POST /accounts', invalid_account
    it_behaves_like '400エラーをチェックする', ['absent_param_content']

    describe '家計簿を登録する' do
      include_context 'POST /accounts', valid_account

      before(:all) { @created_account = @pbody }

      it_behaves_like 'ステータスコードが正しいこと', '201'

      CommonHelper.account_params.each do |key|
        it "レスポンスボディのキーに#{key}が含まれていること" do
          expect(@pbody.keys).to include key
        end
      end

      describe '家計簿を取得する' do
        before(:all) { @id = @created_account['id'] }

        include_context 'GET /accounts/[:id]'

        it_behaves_like 'ステータスコードが正しいこと', '200'

        it '取得された家計簿が正しいこと' do
          actual_account = @pbody.slice(*account_params).symbolize_keys
          expect(actual_account).to eq valid_account
        end

        describe '家計簿を更新する' do
          before(:all) do
            header = {'Authorization' => app_auth_header}.merge(content_type_json)
            @res = http_client.put("#{base_url}/accounts/#{@created_account['id']}", {:account_type => 'income'}.to_json, header)
            @pbody = JSON.parse(@res.body) rescue nil
          end

          it_behaves_like 'ステータスコードが正しいこと', '200'

          it '更新された家計簿が正しいこと' do
            actual_account = @pbody.slice(*account_params).symbolize_keys
            expect(actual_account).to eq valid_account.merge(:account_type => 'income')
          end

          describe '家計簿を検索する' do
            include_context 'GET /accounts', {:account_type => 'income'}
            it_behaves_like 'Request: 家計簿が正しく検索されていることを確認する', valid_account.merge(:account_type => 'income')

            describe '家計簿を削除する' do
              before(:all) do
                header = {'Authorization' => app_auth_header}
                @res = http_client.delete("#{base_url}/accounts/#{@created_account['id']}", header)
                @pbody = JSON.parse(@res.body) rescue nil
              end

              it_behaves_like 'ステータスコードが正しいこと', '204'

              describe '家計簿を取得する' do
                before(:all) { @id = @created_account['id'] }

                include_context 'GET /accounts/[:id]'

                it_behaves_like 'ステータスコードが正しいこと', '404'
              end
            end
          end
        end
      end
    end
  end
end
