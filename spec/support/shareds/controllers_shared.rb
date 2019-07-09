# coding: utf-8

shared_examples '収支リソースのレスポンスが正しいこと' do |status: nil, body: nil|
  it 'ステータスコードが正しいこと' do
    is_asserted_by { @response_status == status }
  end

  it 'レスポンスボディが正しいこと' do
    is_asserted_by { @response_body.keys.sort == PaymentHelper.response_keys }

    body.except(:categories).each do |key, value|
      is_asserted_by { @response_body[key.to_s] == value }
    end

    body[:categories].each_with_index do |category, i|
      category.each do |key, value|
        is_asserted_by do
          @response_body['categories'][i].keys.sort == CategoryHelper.response_keys
        end

        is_asserted_by { @response_body['categories'][i][key.to_s] == value }
      end
    end
  end
end

shared_examples '収支検索時のレスポンスが正しいこと' do
  it_is_asserted_by { @response_status == 200 }

  it 'レスポンスボディが正しいこと' do
    is_asserted_by { @response_body.keys.sort == %w[payments] }

    @response_body['payments'].each do |payment|
      is_asserted_by { payment.keys.sort == PaymentHelper.response_keys }

      payment['categories'].each do |category|
        is_asserted_by { category.keys.sort == CategoryHelper.response_keys }
      end
    end
  end
end
