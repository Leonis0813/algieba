# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  shared_context '収支情報を登録する' do |params|
    before(:all) do
      res = client.post('/api/payments', params)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  describe '正常系' do
    base_payment = PaymentHelper.test_payment[:income].except(:id)

    shared_examples 'レスポンスが正しいこと' do |body|
      it_behaves_like 'ステータスコードが正しいこと', 201

      it 'レスポンスボディが正しいこと' do
        is_asserted_by { @response_body.keys.sort == PaymentHelper.response_keys }

        body.except(:payment_id, :categories, :tags).each do |key, value|
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

        body[:tags].each_with_index do |tag, i|
          tag.each do |key, value|
            is_asserted_by do
              @response_body['tags'][i].keys.sort == TagHelper.response_keys
            end

            is_asserted_by { @response_body['tags'][i][key.to_s] == value }
          end
        end
      end
    end

    [
      ['カテゴリが既に存在している場合', {}],
      ['カテゴリが存在しない場合', {categories: ['not_exist']}],
      ['複数のカテゴリを指定した場合', {categories: %w[algieba other_category]}],
    ].each do |description, categories|
      context description do
        body = base_payment.merge(categories)
        response_categories = body[:categories].map do |category_name|
          {name: category_name, description: nil}
        end
        response_tags = body[:tags].map {|tag_name| {name: tag_name} }
        expected_response = body.merge(
          categories: response_categories,
          tags: response_tags,
        ).except(:id)

        include_context 'トランザクション作成'
        include_context '収支情報を登録する', body
        it_behaves_like 'レスポンスが正しいこと', expected_response
      end
    end

    [
      ['タグが既に存在している場合', {}],
      ['タグが存在しない場合', {tags: ['not_exist']}],
      ['複数のタグを指定した場合', {tags: %w[algieba other_tag]}],
    ].each do |description, tags|
      context description do
        body = base_payment.merge(tags)
        response_categories = body[:categories].map do |category_name|
          {name: category_name, description: nil}
        end
        response_tags = body[:tags].map {|tag_name| {name: tag_name} }
        expected_response = body.merge(
          categories: response_categories,
          tags: response_tags,
        ).except(:id)

        include_context 'トランザクション作成'
        include_context '収支情報を登録する', body
        it_behaves_like 'レスポンスが正しいこと', expected_response
      end
    end

    context 'タグを指定しない場合' do
      body = base_payment.except(:tags)
      response_categories = body[:categories].map do |category_name|
        {name: category_name, description: nil}
      end
      expected_response = body.merge(
        categories: response_categories,
        tags: [],
      ).except(:id)

      include_context 'トランザクション作成'
      include_context '収支情報を登録する', body
      it_behaves_like 'レスポンスが正しいこと', expected_response
    end
  end

  describe '異常系' do
    payment_params = (PaymentHelper.response_keys - %w[payment_id tags]).map(&:to_sym)
    test_cases = [].tap do |tests|
      (payment_params.size - 1).times do |i|
        tests << payment_params.combination(i + 1).to_a
      end
    end.flatten(1)

    test_cases.each do |absent_keys|
      context "#{absent_keys.join(',')}がない場合" do
        selected_keys = payment_params - absent_keys
        income = PaymentHelper.test_payment[:income].slice(*selected_keys)
        errors = absent_keys.sort.map {|key| {'error_code' => "absent_param_#{key}"} }
        include_context 'トランザクション作成'
        include_context '収支情報を登録する', income
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end

    [
      {payment_type: 'invalid_type'},
      {date: 'invalid_date'},
      {price: 'invalid_price'},
      {payment_type: 'invalid_type', date: 'invalid_date', price: 'invalid_price'},
    ].each do |invalid_param|
      context "#{invalid_param.keys.join(',')}が不正な場合" do
        expense = PaymentHelper.test_payment[:expense].merge(invalid_param)
        errors = invalid_param.keys.sort.map do |key|
          {'error_code' => "invalid_param_#{key}"}
        end
        include_context 'トランザクション作成'
        include_context '収支情報を登録する', expense
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end
  end
end
