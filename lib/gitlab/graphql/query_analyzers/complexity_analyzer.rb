module Gitlab
  module Graphql
    module QueryAnalyzers
      class ComplexityAnalyzer
        # Called before initializing the analyzer.
        # Returns true to run this analyzer, or false to skip it.
        def analyze?(query)
          # TODO can I safely carve off all the improvements
          # that would still work when this is enabled into a separate branch?
          Feature.enabled?(:graphql_new_complexity_analyzer, default_enabled: true)
        end

        # Called before the visit.
        # Returns the initial value for `memo`
        def initial_value(query)
          ComplexityAnalyzerMemo.new(query)
        end

        # TODO might have to make a whole lot of fields have a complexity of 0
        # TODO we might have to make complexity required for all fields, arguments, resolvers? (types??)
        # unless it can get defined in a resolver instead of a field?
        # fields can be exempt if they have a resolver: defined
        # TODO DOCS! Argument complexity and field complexity
        # TODO can I switch the old complexity analyzer off??
        # I mean, it can run and this will always calculate higher scores
        # so it doesn't matter?
        # TODO possible a logical breaking thing, where if
        # we've entered > x number of times, then we just break and fail?
        def call(memo, visit_type, irep_node)
          if irep_node.ast_node.is_a?(GraphQL::Language::Nodes::Field)
            if visit_type == :enter
              memo.current_node = memo.current_node.new_child(irep_node)
            else
              memo.current_node = memo.current_node.parent
            end
          end

          memo
        end

        # Called when we're done the whole visit.
        def final_value(memo)
          complexity = memo.complexity
          max_complexity = memo.max_complexity

          # Rails.logger.debug("GraphQL Query complexity: #{complexity}")
          GraphqlLogger.info("GraphQL Query complexity: #{complexity}")

          if complexity > max_complexity
            GraphQL::AnalysisError.new("Query has complexity of #{complexity}, which exceeds max complexity of #{max_complexity}")
          end
        end

        class ComplexityAnalyzerMemo
          attr_accessor :current_node

          def initialize(query)
            @context = query.context
            node = OpenStruct.new(name: 'QueryRoot')
            @tree = @current_node = ASTNode.new(node, parent: nil, context: @context)
          end

          def complexity
            @complexity ||= tree.calculate(tree.child_multiplier)
          end

          def max_complexity
            # TODO perhaps we can get this through the schema of the node?
            @max_complexity ||= GitlabSchema.max_query_complexity(context)
          end

          private

          attr_reader :tree, :context
        end

        class ASTNode
          attr_accessor :child_multiplier, :parent

          def initialize(node, parent:, context:)
            @node = node
            @name = node.name
            @parent = parent
            @children = []
            @context = context
            @complexity = determine_complexity
            @child_multiplier = determine_multiplier
          end

          def new_child(node)
            child = self.class.new(node, parent: self, context: context)
            children << child
            child
          end

          # Calculates from this node down
          def calculate(multiplier)
            total = complexity + children.sum do |child|
              child.calculate(child_multiplier)
            end

            total * multiplier
          end

          def inspect
            "#<%s name=%s complexity=%d child_multiplier=%d children=#{children}>" %
              [self.class.name.demodulize, name, complexity, child_multiplier]
          end

          private

          attr_accessor :children, :complexity, :context, :name, :node

          def determine_complexity
            return 0 if ignored_node?
            return 0 if introspection?

            complexity = extract_complexity_value(node.definition.complexity)
            # Add any complexity from Arguments with `complexity` keyword args
            complexity += node.arguments.argument_values.values.sum do |arg|
              extract_complexity_value(
                arg.definition.metadata[:complexity]
              )
            end
          end

          # Complexity can be defined as numeric or a Proc.
          def extract_complexity_value(complexity)
            return 0 unless complexity

            if complexity.is_a?(Proc)
              # TODO this is different to https://github.com/rmosolgo/graphql-ruby/blob/master/guides/queries/complexity_and_depth.md#prevent-complex-queries
              # so we need to document this change and that we use a different
              # complexity analyzer. I don't believe we need
              # child_complexity because this analyzer does that already.
              complexity = complexity.call(context, node.arguments)
            end

            unless complexity.is_a?(Numeric)
              raise ArgumentError, ":complexity for field or argument :#{name} must be either numeric or a Proc"
            end

            complexity
          end

          def determine_multiplier
            return 0 if introspection?
            # Only connections will have a child multiplier
            # TODO do we need to care about array types or do we not do them?
            return 1 unless connection?
            # O(1) complexity means the complexity of children shouldn't be multiplied.
            # No matter how many children there are, the complexity doesn't increase
            # from if there is one child to if there are `max_page_size` children
            return 1 if node.definition.metadata[:complexity_type] == :'O(1)'

            # The rest are considered to have a complexity type of O(N)
            # I.e., for every child node we start multiplying the complexity
            # So the remaingin code determines the max number of children
            # this query can return

            args = node.arguments.to_h.symbolize_keys

            # Take initial limit from:
            # - id or iid, which will limit the number of results that can be returned to 1
            # - ids.count and iids.count which limit the number to the array size of that argument
            limit = case
                    when args[:id], args[:iid]
                      1
                    when args[:ids], args[:iids]
                      # If both are given, choose the length of the smallest Array
                      args.slice(:ids, :iids).values.map(&:length).min
                    else
                      ::GitlabSchema::DEFAULT_MAX_PAGE_SIZE
                    end

            # Factor in the `first` and `last` arguments, which limit the number
            # of records to that number
            if (limiting_arg = args.slice(:first, :last).values.first)
              limit = [limit, limiting_arg].min
            end

            limit
          end

          def root?
            parent.nil?
          end

          def introspection?
            node.definition&.introspection?
          end

          def connection?
            node.definition&.connection?
          end

          def ignored_node?
            root? || ::Gitlab::Graphql::QueryAnalyzers::IGNORED_FIELDS.include?(node.name)
          end
        end
      end
    end
  end
end
