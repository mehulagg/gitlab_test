# frozen_string_literal: true

module API
  module Monitoring
    class Annotations < Grape::API
      # desc 'Create a new monitoring dashboard annotation' do
      #   success Entities::Issue
      # end
      params do
        requires :from, type: DateTime,
                 desc: 'Date time indicating starting moment to which the annotation relates.'
        optional :to, type: DateTime,
                 desc: 'Date time indicating ending moment to which the annotation relates.'
        requires :dashboard_id, type: String,
                 desc: 'The ID of the dashboard on which the annotation should be added'
        optional :panel_id, type: String,
                 desc: 'The ID of the panel on which the annotation should be added'
        optional :tags, type: Array[String],
                 desc: 'The ID of the panel on which the annotation should be added'
        requires :description, type: String, desc: 'The description of the annotation'
        optional :environment_id, type: Integer, desc: 'The id of environment to which the annotation should belong'
        optional :cluster_id, type: Integer, desc: 'The id of cluster to which the annotation should belong'
        exactly_one_of :cluster_id, :environment_id
      end

      post ':dashboard_id/annotations' do
        binding.pry
        environment = ::Environment.find(params[:environment_id])
        authorize! :maintainer_access, environment

        params
      end
    end
  end
end
