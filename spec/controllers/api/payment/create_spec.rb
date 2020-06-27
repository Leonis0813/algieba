# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  shared_context '収支情報を登録する' do |body: nil|
    before(:all) do
      body ||= @body
      res = client.post('/api/payments', body)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  describe '正常系' do
    shared_examples 'レスポンスが正しいこと' do |body: nil|
      it_behaves_like 'ステータスコードが正しいこと', 201

      it 'レスポンスボディが正しいこと' do
        body ||= @expected_body
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

    valid_attribute = {
      payment_type: %w[income expense],
      date: %w[1000-01-02],
      content: %w[テスト],
      categories: [%w[test]],
      tags: [%w[test]],
      price: [1, 10],
    }

    CommonHelper.generate_test_case(valid_attribute).each do |body|
      context "#{body}を指定する場合" do
        include_context 'トランザクション作成'
        before(:all) do
          payment = build(:payment)
          categories = payment.categories.map(&:name)
          tags = payment.tags.map(&:name)
          @body = payment.slice(:payment_type, :content, :price).merge(
            date: payment.date.strftime('%F'),
            categories: categories,
            tags: tags,
          ).merge(body)

          response_categories = (body[:categories] || categories).map do |category_name|
            {name: category_name, description: nil}
          end
          response_tags = (body[:tags] || tags).map do |tag_name|
            {name: tag_name}
          end
          @expected_body = @body.except(:categories, :tags).merge(
            categories: response_categories,
            tags: response_tags,
          ).deep_stringify_keys
        end

        include_context '収支情報を登録する'
        it_behaves_like 'レスポンスが正しいこと'
      end
    end

    [
      ['カテゴリが既に存在している場合', %w[algieba]],
      ['複数のカテゴリを指定した場合', %w[algieba other_category]],
    ].each do |description, categories|
      context description do
        include_context 'トランザクション作成'
        before(:all) do
          category = create(:category, name: 'algieba')
          payment = build(:payment)
          @body = payment.slice(:payment_type, :content, :price).merge(
            date: payment.date.strftime('%F'),
            categories: categories,
          )

          response_categories = categories.map do |category_name|
            {name: category_name, description: nil}
          end
          @expected_body = @body.except(:categories, :tags).merge(
            categories: response_categories,
            tags: [],
          )
        end
        include_context '収支情報を登録する'
        it_behaves_like 'レスポンスが正しいこと'
      end
    end

    [
      ['タグが既に存在している場合', %w[algieba]],
      ['複数のタグを指定した場合', %w[algieba other_tag]],
    ].each do |description, tags|
      context description do
        include_context 'トランザクション作成'
        before(:all) do
          tag = create(:tag, name: 'algieba')
          payment = build(:payment)
          @body = payment.slice(:payment_type, :content, :price).merge(
            date: payment.date.strftime('%F'),
            categories: payment.categories.map(&:name),
            tags: tags
          )

          response_categories = payment.categories.map do |category|
            {name: category.name, description: nil}
          end
          response_tags = tags.map {|tag_name| {name: tag_name} }
          @expected_body = @body.except(:categories, :tags).merge(
            categories: response_categories,
            tags: response_tags,
          )
        end
        include_context '収支情報を登録する'
        it_behaves_like 'レスポンスが正しいこと'
      end
    end
  end

  describe '異常系' do
    required_keys = %i[payment_type date content price categories]

    CommonHelper.generate_combinations(required_keys).each do |absent_keys|
      context "#{absent_keys.join(',')}がない場合" do
        errors = absent_keys.map do |key|
          {
            'error_code' => 'absent_parameter',
            'parameter' => key.to_s,
            'resource' => 'payment',
          }
        end

        before(:all) do
          payment = build(:payment)
          @body = payment.slice(:payment_type, :content, :price).merge(
            date: payment.date.strftime('%F'),
            categories: payment.categories.map(&:name),
            tags: payment.tags.map(&:name),
          ).except(*absent_keys)
        end
        include_context '収支情報を登録する'
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end

    invalid_attribute = {
      payment_type: [1, 'invalid', ['income'], {type: 'income'}, true],
      date: [1, 'invalid', '1000-13-01', ['1000-01-01'], {date: '1000-01-01'}, true],
      content: [['test'], {content: 'test'}], # add cases after removing capybara
      price: [[1], {price: 1}], # add cases after removing capybara
    }
    CommonHelper.generate_test_case(invalid_attribute).each do |body|
      context "#{body.keys.join(',')}が不正な場合" do
        errors = body.keys.map do |key|
          {
            'error_code' => 'invalid_parameter',
            'parameter' => key.to_s,
            'resource' => 'payment',
          }
        end
        before(:all) do
          payment = build(:payment)
          @body = payment.slice(:payment_type, :content, :price).merge(
            date: payment.date.strftime('%F'),
            categories: payment.categories.map(&:name),
            tags: payment.tags.map(&:name),
          ).merge(body)
        end
        include_context '収支情報を登録する'
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end

    context 'categoriesが不正な場合' do
      errors = [
        {
          'error_code' => 'invalid_parameter',
          'parameter' => 'categories',
          'resource' => 'payment',
        }
      ]
      before(:all) do
        payment = build(:payment)
        @body = payment.slice(:payment_type, :content, :price).merge(
          date: payment.date.strftime('%F'),
          categories: [{category: 'test'}],
        )
      end
      include_context '収支情報を登録する'
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end

    context 'categoriesに同じ値が含まれている場合' do
      errors = [
        {
          'error_code' => 'include_same_value',
          'parameter' => 'categories',
          'resource' => 'payment',
        }
      ]
      before(:all) do
        payment = build(:payment)
        @body = payment.slice(:payment_type, :content, :price).merge(
          date: payment.date.strftime('%F'),
          categories: %w[test test],
        )
      end
      include_context '収支情報を登録する'
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end

    [['0' * 11], [{tag: 'test'}]].each do |tags|
      context 'tagsが不正な場合' do
        errors = [
          {
            'error_code' => 'invalid_parameter',
            'parameter' => 'tags',
            'resource' => 'payment',
          }
        ]
        before(:all) do
          payment = build(:payment)
          @body = payment.slice(:payment_type, :content, :price).merge(
            date: payment.date.strftime('%F'),
            categories: %w[test],
            tags: tags,
          )
        end
        include_context '収支情報を登録する'
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end

    context 'tagsに同じ値が指定されている場合' do
      errors = [
        {
          'error_code' => 'include_same_value',
          'parameter' => 'tags',
          'resource' => 'payment',
        }
      ]
      before(:all) do
        payment = build(:payment)
        @body = payment.slice(:payment_type, :content, :price).merge(
          date: payment.date.strftime('%F'),
          categories: %w[test],
          tags: %w[test test],
        )
      end
      include_context '収支情報を登録する'
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end

    context '複合エラーの場合' do
      errors = [
        {
          'error_code' => 'absent_parameter',
          'parameter' => 'payment_type',
          'resource' => 'payment',
        },
        {
          'error_code' => 'invalid_parameter',
          'parameter' => 'date',
          'resource' => 'payment',
        },
        {
          'error_code' => 'include_same_value',
          'parameter' => 'tags',
          'resource' => 'payment',
        },
      ]
      before(:all) do
        payment = build(:payment)
        @body = payment.slice(:content, :price).merge(
          date: 'invalid',
          categories: %w[test],
          tags: %w[test test],
        )
      end
      include_context '収支情報を登録する'
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end
  end
end
