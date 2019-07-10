class BadRequest < StandardError
  attr_accessor :errors

  def initialize(error_codes)
    @errors = Array.wrap(error_codes).sort.map do |error_code|
      {error_code: error_code}
    end
  end
end
