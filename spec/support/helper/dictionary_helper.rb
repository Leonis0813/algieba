# coding: utf-8

module DictionaryHelper
  module_function

  def response_keys
    @response_keys ||= %w[id phrase condition categories].sort
  end
end
