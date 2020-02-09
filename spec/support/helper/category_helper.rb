# coding: utf-8

module CategoryHelper
  module_function

  def response_keys
    @response_keys ||= %w[category_id name description].sort
  end
end
