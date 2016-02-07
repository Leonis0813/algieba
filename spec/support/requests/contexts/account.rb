# coding: utf-8

shared_context '共通設定' do
  before(:all) do
    @base_url = 'http://160.16.66.112:88'
    @content_type_json = {'Content-Type' => 'application/json'}
    @hc = HTTPClient.new
  end
end

shared_context 'POST /accounts' do |account|
  before(:all) do
    @res = @hc.post("#{@base_url}/accounts", {:accounts => account}.to_json, @content_type_json)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'GET /accounts' do |condition|
  before(:all) do
    @res = @hc.get("#{@base_url}/accounts", condition)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'PUT /accounts' do |condition, with|
  before(:all) do
    @res = @hc.put("#{@base_url}/accounts", {:condition => condition, :with => with}.to_json, @content_type_json)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'DELETE /accounts' do |condition|
  before(:all) do
    @res = @hc.delete("#{@base_url}/accounts", condition)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'GET /settlement' do |interval|
  before(:all) do
    @res = @hc.get("#{@base_url}/settlement", :interval => interval)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end
