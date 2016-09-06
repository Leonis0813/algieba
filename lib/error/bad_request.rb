class Error::BadRequest < StandardError
  attr_accessor :errors

  def initialize(errors, prefix)
    @errors = Array.wrap(errors).map do |error|
      {:error_code => "#{prefix}_param_#{error}"}
    end
  end
end
