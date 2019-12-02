# frozen_string_literal: true

module API
  module SqlEntities
    class Pipeline
      class JsonBlob
        def initialize(json)
          @json = json
        end

        def to_json(*_args)
          @json
        end
      end

      ID_PLACEHOLDER = 'PIPELINE_ID'.freeze
      EMPTY_JSON_ARRAY = JSON.dump([])

      class << self
        # rubocop: disable CodeReuse/ActiveRecord
        def present_collection(scope:, project:)
          subquery = scope.select(
            :id,
            :sha,
            :ref,
            :status,
            cast_timestamp_field(arel_table[:created_at]),
            cast_timestamp_field(arel_table[:updated_at]),
            pipeline_url(project)
          ).arel.as(table_name)

          sql = Ci::Pipeline.select(array_to_json.as('result')).from(subquery).to_sql

          JsonBlob.new(ActiveRecord::Base.connection.execute(sql).first['result'] || EMPTY_JSON_ARRAY)
        end
        # rubocop: enable CodeReuse/ActiveRecord

        private

        def pipeline_url(project)
          url = ActiveRecord::Base.connection.quote(Gitlab::Routing.url_helpers.project_pipeline_url(project, ID_PLACEHOLDER))

          Arel::Nodes::NamedFunction.new('REPLACE', [Arel.sql(url), quoted_id_placeholder, id_as_varchar]).as('web_url')
        end

        def cast_timestamp_field(field)
          Arel::Nodes::NamedFunction.new('TO_CHAR', [field, timestamp_format]).as(field.name.to_s)
        end

        def arel_table
          Ci::Pipeline.arel_table
        end

        def table_name
          Arel.sql(Ci::Pipeline.table_name)
        end

        def array_to_json
          Arel::Nodes::NamedFunction.new('ARRAY_TO_JSON', [
            Arel::Nodes::NamedFunction.new('ARRAY_AGG', [
              Arel::Nodes::NamedFunction.new('ROW_TO_JSON', [table_name])
            ])
          ])
        end

        def id_as_varchar
          Arel::Nodes::NamedFunction.new('CAST', [arel_table[:id].as('VARCHAR')])
        end

        def quoted_id_placeholder
          Arel.sql(ActiveRecord::Base.connection.quote(ID_PLACEHOLDER))
        end

        def timestamp_format
          Arel.sql(ActiveRecord::Base.connection.quote('YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'))
        end
      end
    end
  end
end
