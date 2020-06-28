class ApplicationValidator < ActiveModel::EachValidator
  ERROR_MESSAGE = {
    absent: 'absent_parameter',
    invalid: 'invalid_parameter',
    duplicated: 'duplicated_resource',
    same_value: 'include_same_value',
  }.freeze
end
