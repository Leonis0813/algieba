class Query
  include ActiveModel::Model

  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10
  DEFAULT_ORDER = 'asc'.freeze
  ORDER_LIST = [DEFAULT_ORDER, 'desc'].freeze

  attr_accessor :page, :per_page, :order

  validates :page, :per_page,
            integer: {greater_than: 0}
  validates :order,
            string: {enum: ORDER_LIST}

  def initialize(attributes = {})
    super
    self.page ||= DEFAULT_PAGE
    self.per_page ||= DEFAULT_PER_PAGE
    self.order ||= DEFAULT_ORDER
  end
end
