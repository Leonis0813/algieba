# coding: utf-8
case Rails.env
when 'development'
  [
    Category.new(name: 'zosma'),
    Payment.new(
      id: 1,
      payment_type: 'expense',
      date: '1000-01-01',
      content: 'システムテスト用データ',
      price: 100,
    ),
    Payment.new(
      id: 2,
      payment_type: 'income',
      date: '1000-01-01',
      content: 'システムテスト用データ',
      price: 100,
    ),
  ].each do |object|
    begin
      object.save!
    rescue ActiveRecord::RecordNotUnique => e
      puts "[Warning] #{e.message}"
    end
  end
end
