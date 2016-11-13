# coding: utf-8
case Rails.env
when 'development'
  [
    {:id => 1, :account_type => 'expense', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'zosma', :price => 100},
    {:id => 2, :account_type => 'income', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'zosma', :price => 100},
  ].each do |params|
    begin
      Account.create!(params)
    rescue ActiveRecord::RecordNotUnique => e
      puts "[Warning] #{e.message}"
    end
  end

  [
    {:id => 1, :user_id => 'test_user_id', :password => 'test_user_pass'},
  ].each do |params|
    begin
      User.create!(params)
    rescue ActiveRecord::RecordNotUnique => e
      puts "[Warning] #{e.message}"
    end
  end

  [
    {:id => 1, :application_id => 'test_app_id', :application_key => 'test_app_key'},
  ].each do |params|
    begin
      Client.create!(params)
    rescue ActiveRecord::RecordNotUnique => e
      puts "[Warning] #{e.message}"
    end
  end
when 'production'
  [
    {:id => 1, :user_id => 'leonis', :password => '0qpalzm1'},
  ].each do |params|
    begin
      User.create!(params)
    rescue ActiveRecord::RecordNotUnique => e
      puts "[Warning] #{e.message}"
    end
  end
end
