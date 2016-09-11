# coding: utf-8

shared_context 'Model: 家計簿を検索する' do |query = {}|
  before(:all) { @accounts = Account.index(query) }
end

shared_context 'Model: 収支を計算する' do |interval|
  before(:all) { @settlement = Account.settle(interval) }
end

shared_context 'Controller: 共通設定' do
  before(:all) do
    @test_account = {
      :income => {
        :id => 1,
        :account_type => 'income',
        :date => '1000-01-01',
        :content => '機能テスト用データ1',
        :category => 'algieba',
        :price => 1000,
      },
      :expense => {
        :id => 2,
        :account_type => 'expense',
        :date => '1000-01-05',
        :content => '機能テスト用データ2',
        :category => 'algieba',
        :price => 100,
      },
    }
    @account_keys = %w[ account_type date content category price ]
    @client = Capybara.page.driver
  end
end

shared_context 'Controller: 家計簿を検索する' do
  before(:all) do
    @res = @client.get('/accounts.json', @params)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'Controller: 家計簿を更新する' do
  before(:all) do
    @res = @client.put("/accounts/#{@id}.json", @params)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'Controller: 後始末' do
  after(:all) { @client.delete('/accounts') }
end
