# coding: utf-8
require 'rails_helper'

describe '収支を計算する', :type => :request do
  account = {
    :account_type => 'income',
    :date => '1000-01-01',
    :content => 'システムテスト用データ',
    :category => 'システムテスト',
    :price => 100,
  }
  account_keys = CommonHelper.account_params + %w[ id created_at updated_at ]

  before(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/accounts", nil, header)
    @accounts = JSON.parse(res.body)
    @accounts.each do |account|
      http_client.delete("#{base_url}/accounts/#{account['id']}", nil, header)
    end
  end

  after(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/accounts", nil, header)
    JSON.parse(res.body).each do |account|
      http_client.delete("#{base_url}/accounts/#{account['id']}", nil, header)
    end

    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    @accounts.each do |account|
      body = {:accounts => account.slice(*account_params)}.to_json
      http_client.post("#{base_url}/accounts", body, header)
    end
  end

  describe '家計簿を登録する' do
    include_context 'POST /accounts', account

    describe '家計簿を検索する' do
      include_context 'GET /accounts'
      it_behaves_like 'レスポンスボディのキーが正しいこと', account_keys

      [
        ['yearly', /\d{4}/],
        ['monthly', /\d{4}-\d{2}/],
        ['daily', /\d{4}-\d{2}-\d{2}/],
      ].each do |interval, regex|
        describe '収支を計算する' do
          before(:all) do
            header = {'Authorization' => app_auth_header}
            @res = http_client.get("#{base_url}/settlement", {:interval => interval}, header)
            @pbody = JSON.parse(@res.body) rescue nil
          end

          it_behaves_like 'ステータスコードが正しいこと', '200'

          it 'レスポンスボディのキーのフォーマットが正しいこと' do
            @pbody.keys.each {|key| expect(key).to match(regex) }
          end
        end
      end
    end
  end
end
