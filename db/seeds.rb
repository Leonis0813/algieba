# coding: utf-8
[
  Account.new(:id => 1, :account_type => 'expense', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'zosma', :price => 100),
  Account.new(:id => 2, :account_type => 'income', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'zosma', :price => 100),
].each do |account|
  begin
    account.save!
  rescue ActiveRecord::RecordNotUnique => e
    puts "[Warning] #{e.message}"
  end
end
