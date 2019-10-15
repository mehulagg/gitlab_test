# frozen_string_literal: true

module API
  class ElasticsearchIndices < Grape::API
    before { authenticated_as_admin! }

    helpers do
      params :id_param do
        requires :id, type: Integer, desc: 'The ID of the index'
      end

      def find_index
        index = ElasticsearchIndex.find_by_id(params.delete(:id))

        index || not_found!('Elasticsearch Index')
      end

      def present_index(records)
        present records, with: EE::API::Entities::ElasticsearchIndex, current_settings: current_application_settings
      end

      def index_params
        declared_params(include_missing: false)
      end

      def current_application_settings
        @current_application_settings ||=
          ApplicationSetting.current_without_cache || ApplicationSetting.create_from_defaults
      end

      def update_application_settings(attrs)
        service = ApplicationSettings::UpdateService.new(
          current_application_settings,
          current_user,
          attrs
        )

        if service.execute
          true
        else
          render_validation_error!(current_application_settings)
        end
      end
    end

    resource :elasticsearch_indices do
      desc 'Get all Elasticsearch indices' do
        detail 'This feature was introduced in GitLab 12.5.'
        success EE::API::Entities::ElasticsearchIndex
      end
      get do
        present_index ElasticsearchIndex.order_created_asc
      end

      desc 'Get a single Elasticsearch index' do
        detail 'This feature was introduced in GitLab 12.5.'
        success EE::API::Entities::ElasticsearchIndex
      end
      params do
        use :id_param
      end
      get ':id' do
        present_index find_index
      end

      desc 'Create a new Elasticsearch index' do
        detail 'This feature was introduced in GitLab 12.5.'
        success EE::API::Entities::ElasticsearchIndex
      end
      params do
        requires :friendly_name, type: String, desc: 'The user-visible name of the index'
        requires :urls, type: String, desc: 'The URL(s) to use for connecting to Elasticsearch'
        optional :shards, type: Integer, desc: 'The number of shards in the index'
        optional :replicas, type: Integer, desc: 'The number of replicas in the index'
        optional :aws, type: Boolean, desc: 'Use AWS hosted Elasticsearch'

        given :aws do
          requires :aws_region, type: String, desc: 'The AWS region'
          optional :aws_access_key, type: String, desc: 'The AWS access key'
          optional :aws_secret_access_key, type: String, desc: 'The AWS secret access key'
        end
      end
      post do
        index = Elastic::CreateIndexService.new(current_user, index_params).execute

        if index.persisted?
          present_index index
        else
          render_validation_error!(index)
        end
      end

      desc 'Edit an Elasticsearch index' do
        detail 'This feature was introduced in GitLab 12.5.'
        success EE::API::Entities::ElasticsearchIndex
      end
      params do
        use :id_param
        optional :friendly_name, type: String, desc: 'The user-visible name of the index'
        optional :urls, type: String, desc: 'The URL(s) to use for connecting to Elasticsearch'
        optional :aws, type: Boolean, desc: 'Use AWS hosted Elasticsearch'

        given :aws do
          optional :aws_region, type: String, desc: 'The AWS region'
          optional :aws_access_key, type: String, desc: 'The AWS access key'
          optional :aws_secret_access_key, type: String, desc: 'The AWS secret access key'
        end
      end
      put ':id' do
        index = find_index

        if index.update(index_params)
          present_index index
        else
          render_validation_error!(index)
        end
      end

      desc 'Delete an Elasticsearch index' do
        detail 'This feature was introduced in GitLab 12.5.'
      end
      params do
        use :id_param
      end
      delete ':id' do
        index = find_index
        index = Elastic::DestroyIndexService.new(current_user, index).execute

        if index.destroyed?
          no_content!
        else
          render_validation_error!(index)
        end
      end

      desc 'Change the active Elasticsearch source' do
        detail 'This feature was introduced in GitLab 12.5.'
      end
      params do
        use :id_param
      end
      post 'mark_active_search_source/:id' do
        index = find_index

        if update_application_settings(elasticsearch_read_index: index)
          no_content!
        end
      end

      desc 'Toggle Elasticsearch indexing' do
        detail 'This feature was introduced in GitLab 12.5.'
      end
      params do
        requires :indexing, type: Boolean, desc: 'Whether to enable or disable indexing'
      end
      post 'toggle_indexing' do
        if update_application_settings(elasticsearch_indexing: params[:indexing])
          no_content!
        end
      end

      desc 'Start a reindexing job for Elasticsearch' do
        detail 'This feature was introduced in GitLab 12.5.'
      end
      post 'reindex' do
        unless current_application_settings.elasticsearch_indexing
          update_application_settings(elasticsearch_indexing: true)
        end

        Elastic::IndexProjectsService.new.execute

        no_content!
      end
    end
  end
end
