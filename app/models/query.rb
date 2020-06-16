class Query
  include ActiveModel::Model

  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10
  DEFAULT_ORDER = 'asc'.freeze
  ORDER_LIST = [DEFAULT_ORDER, 'desc'].freeze

  attr_accessor :page, :per_page, :order

  validates :page, :per_page,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              message: ApplicationRecord::MESSAGE_INVALID,
            }
  validates :order,
            inclusion: {in: ORDER_LIST, message: ApplicationRecord::MESSAGE_INVALID}

  def initialize(attributes = {})
    super
    self.page ||= DEFAULT_PAGE
    self.per_page ||= DEFAULT_PER_PAGE
    self.order ||= DEFAULT_ORDER
  end
end
