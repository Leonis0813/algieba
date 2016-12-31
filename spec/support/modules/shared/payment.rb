# coding: utf-8
shared_context '事前準備: クライアントアプリを作成する' do
  before(:all) do
    params = {:application_id => Settings.application_id, :application_key => Settings.application_key}
    Client.create!(params)
  end

  after(:all) do
    params = {:application_id => Settings.application_id, :application_key => Settings.application_key}
    Client.find_by(params).destroy
  end
end

shared_context '事前準備: 家計簿を登録する' do
  before(:all) { test_payment.each {|_, value| Payment.create!(value) } }
  after(:all) { test_payment.each {|_, value| Payment.find_by(value[:id]).try(:delete) } }
end
