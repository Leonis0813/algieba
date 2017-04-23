# coding: utf-8
module CategoryHelper
  def response_keys
    @response_keys ||= %w[ id name description ]
  end

  module_function :response_keys
end
