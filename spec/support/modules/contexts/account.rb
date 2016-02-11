# coding: utf-8

shared_context 'Model: 家計簿を取得する' do |query = {}|
  before(:all) { @result, @accounts = Account.show(query) }
end

shared_context 'Model: 家計簿を更新する' do |condition, with|
  before(:all) { @result, @accounts = Account.update({:condition => condition, :with => with}) }
end

shared_context 'Model: 家計簿を削除する' do |condition|
  before(:all) { @result, @accounts = Account.destroy(condition) }
end

shared_context 'Model: 収支を計算する' do |interval|
  before(:all) { @result, @settlement = Account.settle(interval) }
end

shared_context 'Controller: 共通設定' do
  before(:all) { @client = Capybara.page.driver }
end

shared_context 'Controller: 家計簿を登録する' do |account|
  before(:each) do
    binding.pry
    res ||= post :create, {:accounts => account}
    pbody ||= JSON.parse(@res.body)
    @res, @pbody = res, pbody
  end
end
