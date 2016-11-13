# coding: utf-8
case Rails.env
when 'development'
  [
    Account.new(:id => 1, :account_type => 'expense', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'zosma', :price => 100),
    Account.new(:id => 2, :account_type => 'income', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'zosma', :price => 100),
    User.new(:id => 1, :user_id => 'test_user_id', :password => 'test_user_pass'),
    Client.new(:id => 1, :application_id => 'test_app_id', :application_key => 'test_app_key'),
  ].each do |object|
    begin
      object.save!
    rescue ActiveRecord::RecordNotUnique => e
      puts "[Warning] #{e.message}"
    end
  end
when 'production'
  [
    User.new(:id => 1, :user_id => 'leonis', :password => '0qpalzm1'),
  ].each do |object|
    begin
      object.save!
    rescue ActiveRecord::RecordNotUnique => e
      puts "[Warning] #{e.message}"
    end
  end
end
