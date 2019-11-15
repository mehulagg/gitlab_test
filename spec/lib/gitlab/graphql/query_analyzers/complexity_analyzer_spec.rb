# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Graphql::QueryAnalyzers::ComplexityAnalyzer do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:type) { type_factory }
  let(:query_string) do
    <<~QUERY
    {
      test {
        name
      }
    }
    QUERY
  end
  # A subclass of `described_class` that captures the complexity result
  let(:analyzer_with_capture) do
    Class.new(described_class) do
      attr_reader :captured_complexity

      def final_value(memo)
        @captured_complexity = memo.complexity

        super(memo)
      end
    end.new
  end
  let(:complexity) { analyzer_with_capture.captured_complexity }

  # Execute the query against a new simple schema that implements the analyzer
  def execute(query_type)
    analyzer = analyzer_with_capture

    schema = Class.new(GraphQL::Schema) do
      query_analyzer(analyzer)
      query(query_type)
    end

    schema.execute(
      query_string,
      context: { current_user: user },
      variables: {}
    )
  end

  before do
    execute(query_type)
  end

  # TODO Test that Proc can receive context and args
  context 'when field has no added complexity' do
    let(:query_type) do
      query_factory do |query|
        query.field :test, type, null: true, resolve: -> (_, _, _) { nil }
      end
    end

    it 'calculates complexity using the default complexity of 1 per field' do
      # - `test` field complexity is 1 (default)
      # - `name` field complexity is 1 (default)
      expect(complexity).to eq(2)
    end
  end

  context 'when the field has a `complexity` set' do
    shared_examples_for 'an analyzer that calculates complexity defined on a field' do
      it do
        # - `test` field has complexity is 5 (`complexity` argument)
        # - `name` field complexity is 1 (default)
        expect(complexity).to eq(6)
      end
    end

    context 'when complexity is numeric' do
      let(:query_type) do
        query_factory do |query|
          query.field :test, type, null: true, complexity: 5, resolve: -> (_, _, _) { nil }
        end
      end

      it_behaves_like 'an analyzer that calculates complexity defined on a field'
    end

    context 'when complexity is a Proc' do
      let(:query_type) do
        query_factory do |query|
          query.field :test, type, null: true, complexity: -> (ctx, args) { 5 }, resolve: -> (_, _, _) { nil }
        end
      end

      it_behaves_like 'an analyzer that calculates complexity defined on a field'
    end
  end

  context "when the field's resolver has a `complexity` set" do
    let(:query_type) do
      query_factory do |query|
        query.field :test, type, null: true, resolver: resolver
      end
    end

    shared_examples_for 'an analyzer that calculates complexity defined on a resolver' do
      it do
        # - `test` field has complexity is 10 (due to the `complexity` of its resolver)
        # - `name` field complexity is 1 (default)
        expect(complexity).to eq(11)
      end
    end

    context 'when complexity is numeric' do
      let(:resolver) do
        Class.new(GraphQL::Schema::Resolver) do
          complexity 10

          def resolve(*_); end
        end
      end

      it_behaves_like 'an analyzer that calculates complexity defined on a resolver'
    end

    context 'when complexity is a Proc' do
      let(:resolver) do
        Class.new(GraphQL::Schema::Resolver) do
          complexity -> (ctx, args) { 10 }

          def resolve(*_); end
        end
      end

      it_behaves_like 'an analyzer that calculates complexity defined on a resolver'
    end
  end

  context 'when there is added complexity through calls_gitaly' do
    let(:query_type) do
      query_factory do |query|
        query.field :test, type, null: true, calls_gitaly: true, resolve: -> (_, _, _) { nil }
      end
    end

    it 'adds calls_gitaly complexity' do
      # - `test` field complexity is 2 (`calls_gitaly` adds 1)
      # - `name` field complexity is 1 (default)
      expect(complexity).to eq(3)
    end
  end

  describe 'when combined with skip directive' do
    let(:query_string) do
      <<~QUERY
      query ($skip: Boolean = #{skip}) {
        test {
          name @skip(if: $skip)
        }
      }
      QUERY
    end
    let(:query_type) do
      query_factory do |query|
        query.field :test, type, null: true, resolve: -> (_, _, _) { nil }
      end
    end

    context 'when @skip is true' do
      let(:skip) { true }

      it 'does not calculate complexity on skipped nodes' do
        # - `test` field complexity is 1 (default)
        # - `name` field is skipped
        expect(complexity).to eq(1)
      end
    end

    context 'when @skip is false' do
      let(:skip) { false }

      it 'calculates complexity as normal' do
        # - `test` field complexity is 1 (default)
        # - `name` field complexity is 1 (default)
        expect(complexity).to eq(2)
      end
    end
  end

  context 'when query is an introspection query' do
    let(:query_string) { File.read(Rails.root.join('spec/fixtures/api/graphql/introspection.graphql')) }
    let(:query_type) { query_factory }

    it 'calculates complexity as 0' do
      expect(complexity).to eq(0)
    end
  end

  describe 'calculating complexity on connections' do
    let(:query_type) do
      query_factory do |query|
        query.field :tests, type.connection_type, null: true, resolve: -> (_, _, _) { [] } do
          argument :id, GraphQL::ID_TYPE, required: false
          argument :iid, GraphQL::ID_TYPE, required: false
          argument :ids, [GraphQL::ID_TYPE], required: false
          argument :iids, [GraphQL::ID_TYPE], required: false
          argument :complex_sort, GraphQL::BOOLEAN_TYPE, required: false, complexity: 2
          argument :complex_sort_proc_complexity, GraphQL::BOOLEAN_TYPE, required: false, complexity: -> (ctx, args) { 2 }
        end
      end
    end

    context 'when there are no arguments limiting the number of returned records' do
      let(:query_string) do
        <<~QUERY
        {
          tests {
            nodes {
              name
            }
          }
        }
        QUERY
      end

      it 'calculates complexity using the default max page size of 100' do
        # - `tests` field complexity is 1 (default)
        # - `name` field complexity is 100 (due to max page size of 100)
        expect(complexity).to eq(101)
      end
    end

    context 'when there is a `first` argument limiting the number of returned records' do
      let(:query_string) do
        <<~QUERY
        {
          tests(first: 10) {
            nodes {
              name
            }
          }
        }
        QUERY
      end

      it 'calculates complexity with respect of the `first` argument' do
        # - `test` field complexity is 1 (default)
        # - `name` field complexity is 10 (due to `first` argument limiting collection to max of 10 records)
        expect(complexity).to eq(11)
      end
    end

    context 'when there is a `last` argument limiting the number of returned records' do
      let(:query_string) do
        <<~QUERY
        {
          tests(last: 10) {
            nodes {
              name
            }
          }
        }
        QUERY
      end

      it 'calculates complexity with respect of the `last` argument' do
        # - `test` field complexity is 1 (default)
        # - `name` field complexity is 10 (due to `last` argument limiting collection to max of 10 records)
        expect(complexity).to eq(11)
      end
    end

    context 'when there is an `id` argument' do
      let(:query_string) do
        <<~QUERY
        {
          tests(id: "1") {
            nodes {
              name
            }
          }
        }
        QUERY
      end

      it 'calculates complexity with respect of the `id` argument' do
        # - `test` field complexity is 1 (default)
        # - `name` field complexity is 1 (due to `id` argument limiting collection to max of 1 record)
        expect(complexity).to eq(2)
      end
    end

    context 'when there is an `iid` argument' do
      let(:query_string) do
        <<~QUERY
        {
          tests(iid: "1") {
            nodes {
              name
            }
          }
        }
        QUERY
      end

      it 'calculates complexity with respect of the `iid` argument' do
        # - `test` field complexity is 1 (default)
        # - `name` field complexity is 1 (due to `iid` argument limiting collection to max of 1 record)
        expect(complexity).to eq(2)
      end
    end

    context 'when there is an `ids` argument' do
      let(:query_string) do
        <<~QUERY
        {
          tests(ids: ["1", "2", "3"]) {
            nodes {
              name
            }
          }
        }
        QUERY
      end

      it 'calculates complexity with respect of the `ids` argument' do
        # - `test` field complexity is 1 (default)
        # - `name` field complexity is 3 (due to `ids` argument limiting collection to max of 3 records)
        expect(complexity).to eq(4)
      end
    end

    context 'when there is an `iids` argument' do
      let(:query_string) do
        <<~QUERY
        {
          tests(iids: ["1", "2", "3"]) {
            nodes {
              name
            }
          }
        }
        QUERY
      end

      it 'calculates complexity with respect of the `iids` argument' do
        # - `test` field complexity is 1 (default)
        # - `name` field complexity is 3 (due to `iids` argument limiting collection to max of 3 records)
        expect(complexity).to eq(4)
      end
    end

    context 'when there is an argument that has a `complexity` set' do
      shared_examples_for 'an analyzer that calculates complexity defined on an argument' do
        it do
          # - `test` field complexity is 3 (due to `complexity` of the argument)
          # - `name` field complexity is 100 (due to max page size of 100)
          expect(complexity).to eq(103)
        end
      end

      context 'when complexity on the argument is numeric' do
        let(:query_string) do
          <<~QUERY
          {
            tests(complexSort: true) { # using the `complex_sort` argument defined in `query_type`
              nodes {
                name
              }
            }
          }
          QUERY
        end

        it_behaves_like 'an analyzer that calculates complexity defined on an argument'
      end

      context 'when complexity on the argument is a Proc' do
        let(:query_string) do
          <<~QUERY
          {
            tests(complexSortProcComplexity: true) {  # using the `complex_sort_proc_complexity` argument defined in `query_type`
              nodes {
                name
              }
            }
          }
          QUERY
        end

        it_behaves_like 'an analyzer that calculates complexity defined on an argument'
      end
    end

    context 'when the connection has a O(1) complexity type' do
      let(:query_type) do
        query_factory do |query|
          query.field :tests, type.connection_type, null: true, complexity: 2, complexity_type: :'O(1)', resolve: -> (_, _, _) { [] }
        end
      end
      let(:query_string) do
        <<~QUERY
        {
          tests {
            nodes {
              name
            }
          }
        }
        QUERY
      end

      it 'calculates complexity with respect of the `complexity` of the argument' do
        # - `tests` field complexity is 2 (due to `complexity` of the argument)
        # - `name` field complexity is 1 (due to the `complexity_type` of O(1) on `tests`)
        expect(complexity).to eq(3)
      end
    end
  end

  describe 'calculating complexity on nested connections' do
    let(:second_type) do
      type_factory do |type|
        type.graphql_name 'SecondTestType'
        type.field :more_tests, type.connection_type, null: true, resolve: -> (_, _, _) { [] }
      end
    end
    let(:query_type) do
      query_factory do |query|
        query.field :tests, second_type.connection_type, null: true, resolve: -> (_, _, _) { [] }
      end
    end

    describe 'a simple query' do
      let(:query_string) do
        <<~QUERY
        {
          tests {
            nodes {
              moreTests {
                nodes {
                  name
                }
              }
            }
          }
        }
        QUERY
      end

      it 'calculates complexity using the default max page size of 100' do
        # - `tests` field complexity is 1 (default)
        # - `more_tests` field complexity is 100 (due to max page size of 100)
        # - `name` field complexity is 10000 (due to there being a max of 100 `more_tests` and a max page size of 100)
        expect(complexity).to eq(10101)
      end
    end

    describe 'a query that limits records with a schema that has custom complexities' do
      let(:second_type) do
        type_factory do |type|
          type.field :more_tests, type.connection_type, null: true, complexity: 3, resolve: -> (_, _, _) { [] } do
            argument :complex_sort, GraphQL::BOOLEAN_TYPE, required: false, complexity: 2
          end
        end
      end
      let(:query_string) do
        <<~QUERY
        {
          tests(first: 10) {
            nodes {
              moreTests(complexSort: true) {
                nodes {
                  name
                }
              }
            }
          }
        }
        QUERY
      end

      it 'calculates complexity with respect of the limiting args and field complexity' do
        # - `tests` field complexity is 1 (default)
        # - `more_tests` field complexity is 50 (due to `first` limiting to 10 results and a field complexity of 3 and argument complexity of 2)
        # - `name` field complexity is 1000 (due to there being a max of 10 `more_tests` and a max page size of 100)
        expect(complexity).to eq(1051)
      end
    end
  end
end
