class Settlement
  include ActiveModel::Model

  attr_accessor :interval

  validates :interval,
            presence: {message: 'absent'},
            inclusion: {in: %w[daily monthly yearly], message: 'invalid'}
end
