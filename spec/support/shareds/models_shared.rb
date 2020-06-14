# coding: utf-8

shared_examples '正常な値を指定した場合のテスト' do |valid_attribute|
  CommonHelper.generate_test_case(valid_attribute).each do |attribute|
    it "#{attribute}を指定した場合、エラーにならないこと" do
      object = build(described_class.name.split('::').last.underscore.to_sym, attribute)
      object.validate
      is_asserted_by { object.errors.empty? }
    end
  end
end

shared_examples '必須パラメーターがない場合のテスト' do |absent_keys|
  absent_keys.each do |absent_key|
    it "#{absent_key}がない場合、absentエラーになること" do
      attribute = build(described_class.name.split('::').last.underscore.to_sym)
                  .attributes.except(absent_key.to_s)
      object = described_class.new(attribute)
      object.validate
      is_asserted_by { object.errors.present? }
      is_asserted_by { object.errors.messages[absent_key].include?('absent') }
    end
  end
end

shared_examples '不正な値を指定した場合のテスト' do |invalid_attribute|
  CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
    it "#{attribute}を指定した場合、invalidエラーになること" do
      object = build(described_class.name.split('::').last.underscore.to_sym, attribute)
      object.validate
      is_asserted_by { object.errors.present? }

      attribute.keys.each do |invalid_key|
        is_asserted_by { object.errors.messages[invalid_key].include?('invalid') }
      end
    end
  end
end

shared_examples 'エラーメッセージが正しいこと' do |error_keys, message|
  it "#{error_keys.join(',')}がエラーになっていること" do
    is_asserted_by { @object.errors.messages.keys.sort == error_keys.sort }
  end

  error_keys.each do |key|
    it "#{key}のエラーメッセージが正しいこと" do
      is_asserted_by { @object.errors.messages[key] == [message] }
    end
  end
end
