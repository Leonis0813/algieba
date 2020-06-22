class DictionaryQuery < Query
  attr_accessor :phrase_include

  validates :phrase_include,
            string: true,
            allow_nil: true
end
