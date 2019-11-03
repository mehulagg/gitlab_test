# frozen_string_literal: true

FactoryBot.define do
  factory :ci_empty_pipeline, class: Ci::Pipeline do
    source { :push }
    ref { 'master' }
    sha { '97de212e80737a608d939f648d959671fb0a0142' }
    status { 'pending' }
    add_attribute(:protected) { false }

    project

    # TODO: replace the usage of this factory using stub_ci_pipeline_yaml_file instead
    factory :ci_pipeline_without_jobs do
      after(:build) do |pipeline|
        # TODO: this should be removed and stubbed explicitly
        # pipeline.config.instance_variable_set(:@content, YAML.dump({}))
      end
    end

    # TODO: replace the usage of this factory using stub_ci_pipeline_yaml_file instead
    factory :ci_pipeline_with_one_job do
      after(:build) do |pipeline|
        # TODO: this should be removed and stubbed explicitly
        # pipeline.config.instance_variable_set(:@content, YAML.dump({ rspec: { script: "ls" } }))
      end
    end

    # Persist merge request head_pipeline_id
    # on pipeline factories to avoid circular references
    transient { head_pipeline_of { nil } }

    after(:create) do |pipeline, evaluator|
      merge_request = evaluator.head_pipeline_of
      merge_request&.update(head_pipeline: pipeline)
    end

    factory :ci_pipeline do
      # TODO: remove this transient as it should not be used
      transient { config { nil } }

      after(:build) do |pipeline, evaluator|
        if evaluator.config
          # TODO: this should be removed and stubbed explicitly
          # pipeline.config.instance_variable_set(:@content, YAML.dump(evaluator.config))

          # TODO: remove this too
          # Populates pipeline with errors
          # config = Gitlab::Ci::Yaml.new(project: pipeline.project, content: YAML.dump(evaluator.config))
          # pipeline.yaml_errors = config.errors.join(', ') unless config.valid?
        else
          # TODO: this should be removed and stubbed explicitly
          # pipeline.config.instance_variable_set(:@content, File.read(Rails.root.join('spec/support/gitlab_stubs/gitlab_ci.yml')))
        end
      end

      trait :invalid do
        config do
          { rspec: nil }
        end

        failure_reason { :config_error }
      end

      trait :created do
        status { :created }
      end

      trait :preparing do
        status { :preparing }
      end

      trait :blocked do
        status { :manual }
      end

      trait :scheduled do
        status { :scheduled }
      end

      trait :success do
        status { :success }
      end

      trait :running do
        status { :running }
      end

      trait :failed do
        status { :failed }
      end

      trait :protected do
        add_attribute(:protected) { true }
      end

      trait :with_test_reports do
        status { :success }

        after(:build) do |pipeline, evaluator|
          pipeline.builds << build(:ci_build, :test_reports, pipeline: pipeline, project: pipeline.project)
        end
      end

      trait :with_exposed_artifacts do
        status { :success }

        after(:build) do |pipeline, evaluator|
          pipeline.builds << build(:ci_build, :artifacts,
            pipeline: pipeline,
            project: pipeline.project,
            options: { artifacts: { expose_as: 'the artifact', paths: ['ci_artifacts.txt'] } })
        end
      end

      trait :with_job do
        after(:build) do |pipeline, evaluator|
          pipeline.builds << build(:ci_build, pipeline: pipeline, project: pipeline.project)
        end
      end

      trait :auto_devops_source do
        config_source { Ci::Pipeline.config_sources[:auto_devops_source] }
      end

      trait :repository_source do
        config_source { Ci::Pipeline.config_sources[:repository_source] }
      end
    end
  end
end
