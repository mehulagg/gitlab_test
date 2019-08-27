# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        module Elasticsearch
          class Index < QA::Page::Base
            view 'ee/app/views/admin/elasticsearch/show.html.haml' do
              element :elasticsearch_app, required: true
            end

            view 'ee/app/assets/javascripts/elasticsearch/components/es_empty_state.vue' do
              element :es_empty_new
            end

            view 'ee/app/assets/javascripts/elasticsearch/components/es_list.vue' do
              element :es_list
              element :es_list_new
            end

            view 'ee/app/assets/javascripts/elasticsearch/components/es_new_index.vue' do
              element :es_new_index_friendlyname
              element :es_new_index_urls
              element :es_new_index_create
            end

            def add_index_from_empty(name)
              click_element(:es_empty_new)
              fill_element(:es_new_index_friendlyname, name)
              fill_element(:es_new_index_urls, 'http://localhost:9200')
              click_element(:es_new_index_create)

              saved = has_no_element?(:es_new_index_create)

              raise ExpectationNotMet, %q(There was a problem while adding the new GitLab index) unless saved
            end

            def add_index_from_list(name)
              click_element(:es_list_new)
              fill_element(:es_new_index_friendlyname, name)
              fill_element(:es_new_index_urls, 'http://localhost:9200')
              click_element(:es_new_index_create)

              saved = has_no_element?(:es_new_index_create)

              raise ExpectationNotMet, %q(There was a problem while adding the new GitLab index) unless saved
            end
          end
        end
      end
    end
  end
end
