module CommonHelper
  def self.generate_test_case(params)
    [].tap do |test_cases|
      params.keys.size.times do |i|
        params.keys.combination(i + 1).each do |some_keys|
          tmp_test_cases = [].tap do |tests|
            Array.wrap(params[some_keys.first]).each do |value|
              tests << {some_keys.first => value}
            end

            some_keys[1..-1].each do |key|
              tmp_tests = [].tap do |tmp_test|
                tests.each do |test|
                  Array.wrap(params[key]).each do |value|
                    tmp_test << test.merge(key => value)
                  end
                end
              end
              tests = tmp_tests
            end
            break tests
          end
          test_cases << tmp_test_cases
        end
      end
    end.flatten
  end
end
