class Query
  include ActiveModel::Model

  attribute_names = %i[page per_page sort order]
  attr_accessor(*attribute_names)

  validates :page, :per_page,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              message: 'invalid',
            }
  validates :sort, inclusion: {in: %w[payment_id date price], message: 'invalid'}
  validates :order, inclusion: {in: %w[asc desc], message: 'invalid'}

  def initialize(attributes = {})
    super
    self.page ||= 1
    self.per_page ||= 10
    self.sort ||= 'payment_id'
    self.order ||= 'asc'
  end

  def attributes
    self.class.attribute_names.map {|name| [name, send(name)] }.to_h
  end
end
