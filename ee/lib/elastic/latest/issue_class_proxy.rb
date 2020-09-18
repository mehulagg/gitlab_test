# frozen_string_literal: true

module Elastic
  module Latest
    class IssueClassProxy < ApplicationClassProxy
      include StateFilter

      def elastic_search(query, options: {})
        query_hash = if query =~ /#(\d+)\z/
                       iid_query_hash(Regexp.last_match(1))
                     else
                       fields = %w(title^2 description)

                       # We can only allow searching the iid field if the query is
                       # just a number, otherwise Elasticsearch will error since this
                       # field is type integer.
                       fields << "iid^3" if query =~ /\A\d+\z/

                       basic_query_hash(fields, query)
                     end

        options[:features] = 'issues'
        QueryFactory.query_context(:issue) do
          query_hash = QueryFactory.query_context(:authorized) { project_ids_filter(query_hash, options) }
          query_hash = QueryFactory.query_context(:confidentiality) { confidentiality_filter(query_hash, options) }
          query_hash = QueryFactory.query_context(:match) { state_filter(query_hash, options) }
        end

        search(query_hash, options)
      end

      private

      def confidentiality_filter(query_hash, options)
        current_user = options[:current_user]
        project_ids = options[:project_ids]

        return query_hash if current_user&.can_read_all_resources?

        scoped_project_ids = scoped_project_ids(current_user, project_ids)
        authorized_project_ids = authorized_project_ids(current_user, options)

        # we can shortcut the filter if the user is authorized to see
        # all the projects for which this query is scoped on
        unless scoped_project_ids == :any || scoped_project_ids.empty?
          return query_hash if authorized_project_ids.to_set == scoped_project_ids.to_set
        end

        context = QueryFactory.current_query_context
        filter = { term: { confidential: { _name: context.name(:non_confidential), value: false } } }

        if current_user
          filter = {
              bool: {
                should: [
                  { term: { confidential: { _name: context.name(:non_confidential), value: false } } },
                  {
                    bool: {
                      must: [
                        { term: { confidential: true } },
                        {
                          bool: {
                            should: [
                              { term: { author_id: { _name: context.name(:as_author), value: current_user.id } } },
                              { term: { assignee_id: { _name: context.name(:as_assignee), value: current_user.id } } },
                              { terms: { _name: context.name(:project, :membership, :id), project_id: authorized_project_ids } }
                            ]
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            }
        end

        query_hash[:query][:bool][:filter] << filter
        query_hash
      end
    end
  end
end
