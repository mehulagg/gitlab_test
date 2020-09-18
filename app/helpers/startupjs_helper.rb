# frozen_string_literal: true

module StartupjsHelper
  def embed_graphql(query, variables = {})
    queryStr = File.read(File.join(Rails.root, "app/assets/javascripts/#{query}.query.graphql"))

    content = <<~JAVASCRIPT

      window.embedded_queries = window.embedded_queries || [];
      window.embedded_queries.push({ "query": #{queryStr.to_json}, "variables": #{variables.to_json} });
    JAVASCRIPT

    content_tag(:script, content.html_safe)
  end
end
