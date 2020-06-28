class Query
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  DEFAULT_PAGE = '1'.freeze
  DEFAULT_PER_PAGE = '10'.freeze
  DEFAULT_ORDER = 'asc'.freeze
  ORDER_LIST = [DEFAULT_ORDER, 'desc'].freeze
  PAGE_FORMAT = /\A[1-9]\d*\z/.freeze

  attr_accessor :page, :per_page, :order

  validates :page, :per_page,
            string: {format: PAGE_FORMAT}
  validates :order,
            string: {enum: ORDER_LIST}

  after_validation :parse_int

  def initialize(attributes = {})
    super
    self.page ||= DEFAULT_PAGE
    self.per_page ||= DEFAULT_PER_PAGE
    self.order ||= DEFAULT_ORDER
  end

  private

  def parse_int
    return unless errors.empty?

    self.page = self.page&.to_i
    self.per_page = self.per_page&.to_i
  end
end
