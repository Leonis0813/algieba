class Duplicated < StandardError
  attr_accessor :errors

  def initialize(resource)
    @errors = [{error_code: "duplicated_#{resource}"}]
  end
end
