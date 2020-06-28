# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  category_keys = CategoryHelper.response_keys

  shared_context '収支情報を検索する' do |query = {}|
    before(:all) do
      res = client.get('/api/payments', query)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  include_context 'トランザクション作成'
  before(:all) do
    attribute = {
      payment_id: '0' * 32,
      content: '収入',
      date: '1000-01-05',
      categories: [build(:category, name: 'income')],
      tags: [build(:tag, name: 'income')],
      price: 10000,
    }
    @income = create(:payment, attribute)

    attribute = {
      payment_id: '1' * 32,
      payment_type: 'expense',
      content: '支出',
      categories: [build(:category, name: 'expense')],
      tags: [build(:tag, name: 'expense')],
    }
    @expense = create(:payment, attribute)

    expectations = {
      payment_type: [[@income], [@expense]],
      date_before: [[@expense]],
      date_after: [[@income]],
      content_equal: [[@income]],
      content_include: [[@income]],
      category: [[@income]],
      price_upper: [[@income, @expense], [@income]],
      price_lower: [[], [@expense]],
      sort: [[@income, @expense], [@expense, @income], [@expense, @income]],
      page: [[@income, @expense], []],
      per_page: [[@income], [@income, @expense]],
      order: [[@income, @expense], [@expense, @income]],
    }
    @expectations = generate_test_case(expectations)
  end

  describe '正常系' do
    valid_attribute = {
      payment_type: %w[income expense],
      date_before: %w[1000-01-02],
      date_after: %w[1000-01-02],
      content_equal: %w[収入],
      content_include: %w[収],
      category: %w[income],
      price_upper: [0, 5000],
      price_lower: [0, 5000],
      sort: %w[payment_id date price],
      page: [1, 10],
      per_page: [1, 10],
      order: %w[asc desc],
    }

    CommonHelper.generate_test_case(valid_attribute).each_with_index do |query, i|
      context "#{query.keys.join(',')}を指定する場合" do
        before(:all) do
          expectations = @expectations[i].values.inject(:&)
          expected_payments = expectations.map do |payment|
            categories = payment.categories.map do |category|
              category.slice(*category_keys)
            end
            tags = payment.tags.map {|tag| tag.slice(:tag_id, :name) }

            payment.slice(:payment_id, :payment_type, :content, :price).merge(
              date: payment.date.strftime('%F'),
              categories: categories,
              tags: tags,
            )
          end
          @body = {payments: expected_payments}.deep_stringify_keys
        end
        include_context '収支情報を検索する', query
        it_behaves_like 'レスポンスが正しいこと'
      end
    end

    describe '何も指定しない場合' do
      before(:all) do
        expected_payments = [@income, @expense].map do |payment|
          categories = payment.categories.map do |category|
            category.slice(*category_keys)
          end
          tags = payment.tags.map {|tag| tag.slice(:tag_id, :name) }

          payment.slice(:payment_id, :payment_type, :content, :price).merge(
            date: payment.date.strftime('%F'),
            categories: categories,
            tags: tags,
          )
        end
        @body = {payments: expected_payments}.deep_stringify_keys
      end
      include_context '収支情報を検索する'
      it_behaves_like 'レスポンスが正しいこと'
    end
  end

  describe '異常系' do
    invalid_attribute = {
      page: [0, 'invalid', [1], {page: 1}],
      per_page: [0, 'invalid', [1], {per_page: 1}],
      order: ['invalid', ['asc'], {order: 'asc'}],
      payment_type: ['invalid', ['income'], {type: 'income'}],
      date_before: ['invalid', '1000-13-01', ['1000-01-01'], {date: '1000-01-01'}],
      date_after: ['invalid', '1000-13-01', ['1000-01-01'], {date: '1000-01-01'}],
      content_equal: [['test'], {content: 'test'}],
      content_include: [['test'], {content: 'test'}],
      category: [['test'], {category: 'test'}],
      price_upper: [-1, [0], {price: 0}],
      price_lower: [-1, [0], {price: 0}],
      sort: ['invalid', ['date'], {sort: 'date'}],
    }

    CommonHelper.generate_test_case(invalid_attribute).each do |query|
      context "#{query.keys.join(',')}が不正な場合" do
        errors = query.keys.map do |key|
          {
            'error_code' => 'invalid_parameter',
            'parameter' => key.to_s,
            'resource' => nil,
          }
        end
        include_context '収支情報を検索する', query
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end
  end
end
