class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  ID_FORMAT = /\A[0-9a-f]{32}\z/.freeze
  MESSAGE_ABSENT = 'absent_parameter'.freeze
  MESSAGE_INVALID = 'invalid_parameter'.freeze
  MESSAGE_DUPLICATED = 'duplicated_resource'.freeze
end
