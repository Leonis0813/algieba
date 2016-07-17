# coding: utf-8

shared_context '共通設定' do
  before(:all) do
    @base_url = 'http://160.16.66.112:3000'
    @content_type_json = {'Content-Type' => 'application/json'}
    @hc = HTTPClient.new
    @attributes = %w[ account_type date content category price ]
  end
end

shared_context 'POST /accounts' do |account|
  before(:all) do
    @res = @hc.post("#{@base_url}/accounts", {:accounts => account}.to_json, @content_type_json)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'GET /accounts/[:id]' do
  before(:all) do
    @res = @hc.get("#{@base_url}/accounts/#{@id}")
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'PUT /accounts/[:id]' do |params|
  before(:all) do
    @res = @hc.put("#{@base_url}/accounts/#{@id}", params.to_json, @content_type_json)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'GET /accounts' do |params|
  before(:all) do
    @res = @hc.get("#{@base_url}/accounts", params.to_json)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'DELETE /accounts/[:id]' do
  before(:all) do
    @res = @hc.delete("#{@base_url}/accounts/#{@id}")
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'GET /settlement' do |interval|
  before(:all) do
    @res = @hc.get("#{@base_url}/settlement", :interval => interval)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end
