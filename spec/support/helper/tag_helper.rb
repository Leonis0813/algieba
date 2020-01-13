# coding: utf-8

module TagHelper
  module_function

  def response_keys
    @response_keys ||= %w[tag_id name].sort
  end
end
