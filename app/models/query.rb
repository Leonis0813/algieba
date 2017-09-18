class Query < FormBase
  attr_accessor :payment_type

  validates :payment_type, :inclusion => {:in => %w[ income expense ], :message => 'invalid'}, :allow_nil => true
end
