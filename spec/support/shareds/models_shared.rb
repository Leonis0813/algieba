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

shared_examples 'エラーメッセージが正しいこと' do |expected_error|
  it "#{expected_error.keys.join(',')}がエラーになっていること" do
    is_asserted_by { @object.errors.messages.keys.sort == expected_error.keys.sort }
  end

  expected_error.each do |key, message|
    it "#{key}のエラーメッセージが#{message}であること" do
      is_asserted_by { @object.errors.messages[key] == [message] }
    end
  end
end
