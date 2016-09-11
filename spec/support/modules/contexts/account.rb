# coding: utf-8
shared_context '事前準備: 家計簿を登録する' do
  before(:all) { CommonHelper.test_account.each {|_, value| Account.create!(value) } }
  after(:all) { CommonHelper.test_account.each {|_, value| Account.find_by(value[:id]).try(:delete) } }
end
