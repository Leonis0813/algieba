# coding: utf-8
shared_context 'POST /accounts' do |account|
  before(:all) do
    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    @res = http_client.post("#{base_url}/accounts", {:accounts => account}.to_json, header)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'GET /accounts' do |params = {}|
  before(:all) do
    header = {'Authorization' => app_auth_header}
    @res = http_client.get("#{base_url}/accounts", params.to_json, header)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_examples_for 'Request: 家計簿が正しく検索されていることを確認する' do |expected_accounts|
  it_behaves_like 'ステータスコードが正しいこと', '200'

  it '検索された家計簿が正しいこと' do
    actual_accounts = @pbody.map {|account| account.slice(*account_params).symbolize_keys }
    expect(actual_accounts).to eq Array.wrap(expected_accounts)
  end
end
