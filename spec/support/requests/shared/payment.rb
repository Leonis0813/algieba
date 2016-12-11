# coding: utf-8
shared_context 'POST /payments' do |payment|
  before(:all) do
    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    @res = http_client.post("#{base_url}/payments", {:payments => payment}.to_json, header)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'GET /payments' do |params = {}|
  before(:all) do
    header = {'Authorization' => app_auth_header}
    @res = http_client.get("#{base_url}/payments", params.to_json, header)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_examples 'レスポンスボディのキーが正しいこと' do |payment_keys|
  it do
    Array.wrap(@pbody).each {|payment| expect(payment.keys.sort).to eq payment_keys.sort }
  end
end
