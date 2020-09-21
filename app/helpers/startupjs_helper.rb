# frozen_string_literal: true

module StartupjsHelper
  def page_startup_graphql_calls
    @graphql_startup_calls
  end

  def add_page_startup_graphql_call(query, variables = {})
    @graphql_startup_calls ||= []
    queryStr = File.read(File.join(Rails.root, "app/assets/javascripts/#{query}.query.graphql"))
    @graphql_startup_calls << { query: queryStr, variables: {} }
  end
end
