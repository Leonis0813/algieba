class Query
  include ActiveModel::Model

  attr_accessor :page, :per_page, :order

  validates :page, :per_page,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              message: 'invalid',
            }
  validates :order, inclusion: {in: %w[asc desc], message: 'invalid'}

  def initialize(attributes = {})
    super
    self.page ||= 1
    self.per_page ||= 10
    self.order ||= 'asc'
  end
end
