class Settlement
  include ActiveModel::Model

  attr_accessor :interval

  validates :interval, presence: {message: 'absent'}
  validates :interval,
            inclusion: {in: %w[daily monthly yearly], message: 'invalid'},
            allow_nil: true

  def attributes
    {'interval' => interval}
  end
end
