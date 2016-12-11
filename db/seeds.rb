# coding: utf-8
case Rails.env
when 'development'
  [
    Payment.new(:id => 1, :payment_type => 'expense', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'zosma', :price => 100),
    Payment.new(:id => 2, :payment_type => 'income', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'zosma', :price => 100),
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

  [
   Client.new(:id => 1, :application_id => '68c58a4f26cb84bd', :application_key => 'a469856b9b1b873a5230a0e1b36ee170'),
   Client.new(:id => 2, :application_id => '506a160d625ce4ce', :application_key => '63676749f84adaf76f698f35ed3dacaf'),
  ].each do |object|
    begin
      object.save!
    rescue ActiveRecord::RecordNotUnique => e
      puts "[Warning] #{e.message}"
    end
  end
end
