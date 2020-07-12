# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  render_views

  describe '#create' do
    shared_context '収支情報を登録する' do |params: nil|
      before do
        params ||= @params
        @before_payment_count = Payment.count
        @before_category_count = Category.count
        @before_tag_count = Tag.count
        post(:create, params: params, as: :json)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
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

      shared_examples 'DBに収支情報が登録されていること' do
        it_is_asserted_by { Payment.count == @before_payment_count + 1 }
        it do
          is_asserted_by { Payment.exists?(payment_id: @response_body['payment_id']) }
        end
      end

      shared_examples 'DBにカテゴリ情報が登録されていること' do
        it do
          @after_category_count ||= @before_category_count + 1
          is_asserted_by { Category.count == @after_category_count }
        end

        it do
          is_asserted_by do
            @category_names.all? {|name| Category.exists?(name: name) }
          end
        end
      end

      shared_examples 'DBにタグ情報が登録されていること' do
        it do
          @after_tag_count ||= @before_tag_count + 1
          is_asserted_by { Tag.count == @after_tag_count }
        end

        it do
          is_asserted_by { @tag_names.all? {|name| Tag.exists?(name: name) } }
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

      CommonHelper.generate_test_case(valid_attribute).each do |params|
        context "#{params}を指定する場合" do
          include_context 'トランザクション作成'
          before(:all) do
            payment = build(:payment)
            categories = payment.categories.map(&:name)
            tags = payment.tags.map(&:name)
            @params = payment.slice(:payment_type, :content, :price).merge(
              date: payment.date.strftime('%F'),
              categories: categories,
              tags: tags,
            ).merge(params)

            @category_names = params[:categories] || categories
            response_categories = @category_names.map do |category_name|
              {name: category_name, description: nil}
            end

            @tag_names = params[:tags] || tags
            response_tags = @tag_names.map {|tag_name| {name: tag_name} }

            @expected_body = @params.except(:categories, :tags).merge(
              categories: response_categories,
              tags: response_tags,
            ).deep_stringify_keys
          end
          include_context '収支情報を登録する'

          it_behaves_like 'レスポンスが正しいこと'
          it_behaves_like 'DBに収支情報が登録されていること'
          it_behaves_like 'DBにカテゴリ情報が登録されていること'
          it_behaves_like 'DBにタグ情報が登録されていること'
        end
      end

      [
        ['カテゴリが既に存在している場合', []],
        ['複数のカテゴリを指定した場合', %w[other_category]],
      ].each do |description, new_categories|
        context description do
          include_context 'トランザクション作成'
          before(:all) do
            create(:category, name: 'algieba')
            payment = build(:payment)
            @params = payment.slice(:payment_type, :content, :price).merge(
              date: payment.date.strftime('%F'),
              categories: %w[algieba] + new_categories,
            )

            @category_names = new_categories
            response_categories = (%w[algieba] + new_categories).map do |category_name|
              {name: category_name, description: nil}
            end
            @expected_body = @params.except(:categories, :tags).merge(
              categories: response_categories,
              tags: [],
            )
          end
          include_context '収支情報を登録する'
          before do
            @after_category_count = @before_category_count + new_categories.size
          end

          it_behaves_like 'レスポンスが正しいこと'
          it_behaves_like 'DBに収支情報が登録されていること'
          it_behaves_like 'DBにカテゴリ情報が登録されていること'
        end
      end

      [
        ['タグが既に存在している場合', []],
        ['複数のタグを指定した場合', %w[other_tag]],
      ].each do |description, new_tags|
        context description do
          include_context 'トランザクション作成'
          before(:all) do
            create(:tag, name: 'algieba')
            payment = build(:payment)
            @category_names = payment.categories.map(&:name)
            @params = payment.slice(:payment_type, :content, :price).merge(
              date: payment.date.strftime('%F'),
              categories: @category_names,
              tags: %w[algieba] + new_tags,
            )

            response_categories = @category_names.map do |category_name|
              {name: category_name, description: nil}
            end

            @tag_names = new_tags
            response_tags = (%w[algieba] + new_tags).map {|tag_name| {name: tag_name} }
            @expected_body = @params.except(:categories, :tags).merge(
              categories: response_categories,
              tags: response_tags,
            )
          end
          include_context '収支情報を登録する'
          before { @after_tag_count = @before_tag_count + new_tags.size }

          it_behaves_like 'レスポンスが正しいこと'
          it_behaves_like 'DBに収支情報が登録されていること'
          it_behaves_like 'DBにカテゴリ情報が登録されていること'
          it_behaves_like 'DBにタグ情報が登録されていること'
        end
      end
    end

    describe '異常系' do
      shared_examples 'DBにレコードが登録されていないこと' do
        it_is_asserted_by { Payment.count == @before_payment_count }
        it_is_asserted_by { Category.count == @before_category_count }
        it_is_asserted_by { Tag.count == @before_tag_count }
      end

      required_keys = %i[payment_type date content price categories]

      CommonHelper.generate_combinations(required_keys).each do |absent_keys|
        context "#{absent_keys.join(',')}がない場合" do
          errors = absent_keys.map do |key|
            {
              'error_code' => 'absent_parameter',
              'parameter' => key.to_s,
              'resource' => 'payment',
            }
          end.sort_by {|error| [error['error_code'], error['parameter']] }
          body = {'errors' => errors}

          before(:all) do
            payment = build(:payment)
            @params = payment.slice(:payment_type, :content, :price).merge(
              date: payment.date.strftime('%F'),
              categories: payment.categories.map(&:name),
              tags: payment.tags.map(&:name),
            ).except(*absent_keys)
          end
          include_context '収支情報を登録する'

          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
          it_behaves_like 'DBにレコードが登録されていないこと'
        end
      end

      invalid_attribute = {
        payment_type: [1, 'invalid', ['income'], {type: 'income'}, true],
        date: [1, 'invalid', '1000-13-01', ['1000-01-01'], {date: '1000-01-01'}, true],
        content: [1, '', ['test'], {content: 'test'}, true],
        price: [0, '1', [1], {price: 1}, true],
        categories: [
          'test',
          1,
          {name: 'test'},
          true,
          [],
          [''],
          [1],
          [%w[test]],
          [{name: 'test'}],
          [true],
        ],
        tags: [
          'test',
          1,
          {name: 'test'},
          true,
          [''],
          ['1' * 11],
          [1],
          [%w[test]],
          [{name: 'test'}],
          [true],
        ],
      }

      CommonHelper.generate_test_case(invalid_attribute).each do |params|
        context "#{params.keys.join(',')}が不正な場合" do
          errors = params.keys.map do |key|
            {
              'error_code' => 'invalid_parameter',
              'parameter' => key.to_s,
              'resource' => 'payment',
            }
          end.sort_by {|error| [error['error_code'], error['parameter']] }
          body = {'errors' => errors}

          before(:all) do
            payment = build(:payment)
            @params = payment.slice(:payment_type, :content, :price).merge(
              date: payment.date.strftime('%F'),
              categories: payment.categories.map(&:name),
              tags: payment.tags.map(&:name),
            ).merge(params)
          end
          include_context '収支情報を登録する'

          it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
          it_behaves_like 'DBにレコードが登録されていないこと'
        end
      end

      context 'categoriesに同じ値が含まれている場合' do
        errors = [
          {
            'error_code' => 'include_same_value',
            'parameter' => 'categories',
            'resource' => 'payment',
          },
        ]
        body = {'errors' => errors}
        before(:all) do
          payment = build(:payment)
          @params = payment.slice(:payment_type, :content, :price).merge(
            date: payment.date.strftime('%F'),
            categories: %w[test test],
          )
        end
        include_context '収支情報を登録する'

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'DBにレコードが登録されていないこと'
      end

      context 'tagsに同じ値が指定されている場合' do
        errors = [
          {
            'error_code' => 'include_same_value',
            'parameter' => 'tags',
            'resource' => 'payment',
          },
        ]
        body = {'errors' => errors}
        before(:all) do
          payment = build(:payment)
          @params = payment.slice(:payment_type, :content, :price).merge(
            date: payment.date.strftime('%F'),
            categories: %w[test],
            tags: %w[test test],
          )
        end
        include_context '収支情報を登録する'

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'DBにレコードが登録されていないこと'
      end

      context '複合エラーの場合' do
        errors = [
          {
            'error_code' => 'absent_parameter',
            'parameter' => 'payment_type',
            'resource' => 'payment',
          },
          {
            'error_code' => 'include_same_value',
            'parameter' => 'tags',
            'resource' => 'payment',
          },
          {
            'error_code' => 'invalid_parameter',
            'parameter' => 'date',
            'resource' => 'payment',
          },
        ]
        body = {'errors' => errors}
        before(:all) do
          payment = build(:payment)
          @params = payment.slice(:content, :price).merge(
            date: 'invalid',
            categories: %w[test],
            tags: %w[test test],
          )
        end
        include_context '収支情報を登録する'

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'DBにレコードが登録されていないこと'
      end
    end
  end
end
