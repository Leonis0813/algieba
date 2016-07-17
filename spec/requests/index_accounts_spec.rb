# coding: utf-8
require 'rails_helper'

describe '家計簿を検索する', :type => :request do
  valid_accounts = [
    {:account_type => 'income', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'algieba', :price => 1000},
    {:account_type => 'expense', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'algieba', :price => 100},
  ]

  include_context '共通設定'

  describe '家計簿を登録する' do
    include_context 'POST /accounts', valid_accounts[0]
    before(:all) { @created_accounts = [@pbody] }
    it_behaves_like 'Request: 家計簿が正しく登録されていることを確認する'

    describe '家計簿を検索する' do
      include_context 'GET /accounts', :date_after => '1000-01-01'
      it_behaves_like 'Request: 家計簿が正しく検索されていることを確認する'

      describe '家計簿を登録する' do
        include_context 'POST /accounts', valid_accounts[1]
        before(:all) { @created_accounts << @pbody }
        it_behaves_like 'Request: 家計簿が正しく登録されていることを確認する'

        describe '家計簿を更新する' do
          before(:all) { @id = @created_accounts.last['id'] }
          include_context 'PUT /accounts/[:id]', :account_type => 'income'
          it_behaves_like 'Request: 家計簿が正しく更新されていることを確認する'

          describe '家計簿を検索する' do
            include_context 'GET /accounts', :account_type => 'income'
            it_behaves_like 'Request: 家計簿が正しく検索されていることを確認する'
          end

          describe '家計簿を削除する' do
            valid_accounts.size.times do |i|
              before(:all) { @id = @created_accounts[i]['id'] }
              include_context 'DELETE /accounts/[:id]'
              it_behaves_like 'Request: 家計簿が正しく削除されていることを確認する'
            end

            describe '家計簿を検索する' do
              include_context 'GET /accounts'
              it_behaves_like 'Request: 家計簿が正しく検索されていることを確認する'
            end
          end
        end
      end
    end
  end
end
