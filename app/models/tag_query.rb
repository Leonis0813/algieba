class TagQuery < Query
  attr_accessor :name_include

  validates :name_include,
            string: true,
            allow_nil: true
end
