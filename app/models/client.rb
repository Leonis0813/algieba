class Client < ActiveRecord::Base
  class << self
    def generate_application_id
      loop do
        id = SecureRandom.hex(8)
        return id unless Client.find_by(:application_id => id)
      end
    end

    def generate_application_key
      loop do
        key = SecureRandom.hex(16)
        return key unless Client.find_by(:application_key => key)
      end
    end
  end
end
