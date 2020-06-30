class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  ID_FORMAT = /\A[0-9a-f]{32}\z/.freeze
end
