# coding: utf-8

shared_context 'Model: 家計簿を取得する' do |query = {}|
  before(:all) { @accounts = Account.show(query) }
end

shared_context 'Model: 家計簿を更新する' do |condition, with|
  before(:all) { @accounts = Account.update({:condition => condition, :with => with}) }
end

shared_context 'Model: 家計簿を削除する' do |condition|
  before(:all) { @accounts = Account.destroy(condition) }
end

shared_context 'Model: 収支を計算する' do |interval|
  before(:all) { @settlement = Account.settle(interval) }
end

shared_context 'Controller: 共通設定' do
  before(:all) do
    @test_account = {
      :income => {'account_type' => 'income', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100},
      :expense => {'account_type' => 'expense', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100},
    }
    @account_keys = %w[account_type date content category price]
    @client = Capybara.page.driver
  end
end

shared_context 'Controller: 家計簿を登録する' do
  before(:all) do
    @res = @client.post('/accounts', @params)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'Controller: 家計簿を取得する' do
  before(:all) do
    @res = @client.get('/accounts', @params)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'Controller: 家計簿を更新する' do
  before(:all) do
    @res = @client.put('/accounts', @params)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'Controller: 家計簿を削除する' do
  before(:all) do
    @res = @client.delete('/accounts', @params)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'Controller: 収支を計算する' do
  before(:all) do
    @res = @client.get('/settlement', @params)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'Controller: 後始末' do
  after(:all) { @client.delete('/accounts') }
end
