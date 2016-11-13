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

shared_examples 'レスポンスボディのキーが正しいこと' do |account_keys|
  it do
    Array.wrap(@pbody).each {|account| expect(account.keys.sort).to eq account_keys.sort }
  end
end
