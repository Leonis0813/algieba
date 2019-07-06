# coding: utf-8

shared_context 'トランザクション作成' do
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }
end
