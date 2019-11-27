# frozen_string_literal: true

# A state object to centralize logic related to merge request pipelines
class MergeRequest::Pipelines
  include Gitlab::Utils::StrongMemoize

  EVENT = 'merge_request_event'

  def initialize(merge_request)
    @merge_request = merge_request
  end

  attr_reader :merge_request

  delegate :all_commit_shas, :source_project, :source_branch, to: :merge_request

  def all
    return Ci::Pipeline.none unless source_project

    strong_memoize(:all_pipelines) do
      pipelines = Ci::Pipeline.from_union(
        [source_pipelines, detached_pipelines, triggered_for_branch],
      remove_duplicates: false)

      sort(pipelines)
    end
  end

  def actual_head
    filter_by_sha(all, merge_request.diff_head_sha)
      .or(filter_by_source_sha(all, merge_request.diff_head_sha))
      .first
  end

  private

  def filter_by_sha(pipelines, shas)
    pipelines.where(sha: shas)
  end

  def filter_by_source_sha(pipelines, shas)
    pipelines.where(source_sha: shas)
  end

  def triggered_by_merge_request
    source_project.ci_pipelines
      .where(source: :merge_request_event, merge_request: merge_request)
  end

  def detached_pipelines
    filter_by_sha(triggered_by_merge_request, all_commit_shas)
  end

  def source_pipelines
    filter_by_source_sha(triggered_by_merge_request, all_commit_shas)
  end

  def triggered_for_branch
    pipelines = source_project.ci_pipelines
      .where(source: branch_pipeline_sources, ref: source_branch, tag: false)

    filter_by_sha(pipelines, all_commit_shas)
  end

  def sources
    ::Ci::Pipeline.sources
  end

  def branch_pipeline_sources
    strong_memoize(:branch_pipeline_sources) do
      sources.reject { |source| source == EVENT }.values
    end
  end

  def sort(pipelines)
    sql = 'CASE ci_pipelines.source WHEN (?) THEN 0 ELSE 1 END, ci_pipelines.id DESC'
    query = ApplicationRecord.send(:sanitize_sql_array, [sql, sources[:merge_request_event]]) # rubocop:disable GitlabSecurity/PublicSend

    pipelines.order(Arel.sql(query))
  end
end
