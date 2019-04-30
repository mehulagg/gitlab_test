# frozen_string_literal: true

class MergeTrain < ApplicationRecord
  include AfterCommitQueue
  include ::Gitlab::ExclusiveLeaseHelpers

  belongs_to :merge_request
  belongs_to :user
  belongs_to :pipeline, class_name: 'Ci::Pipeline'

  validate :processable

  delegate :project, to: :merge_request

  after_create do |merge_train|
    run_after_commit { MergeTrain.process_async(merge_train.merge_request) }
  end

  after_destroy do |merge_train|
    run_after_commit { MergeTrain.process_async(merge_train.merge_request) }
  end

  class << self
    def all_in_train(merge_request)
      joined_merge_requests(merge_request).order('merge_trains.id ASC')
    end

    def first_in_train(merge_request)
      all_in_train(merge_request).first
    end

    def joined_merge_requests(merge_request)
      MergeRequest.joins(:merge_train)
        .where('merge_requests.target_project_id = ?', merge_request.target_project_id)
        .where('merge_requests.target_branch = ?', merge_request.target_branch)
    end

    def process_async(merge_request)
      MergeTrains::ProcessWorker.perform_async(merge_request.id)
    end

    def process(merge_request)
      in_lock("merge_train:#{merge_request.project.id}-#{merge_request.target_branch}") do
        unsafe_process(merge_request)
      end
    end
  end

  def all_next
    self.class.all_in_train(merge_request).where('merge_trains.id > ?', id)
  end

  def first_in_train?
    !follower_in_train?
  end

  def follower_in_train?
    self.class.all_in_train(merge_request).where('merge_trains.id < ?', id).exists?
  end

  def ensure_pipeline!
    return if pipeline_id.present?

    pipeline = MergeRequests::CreatePipelineService.new(project, user).execute(merge_request)

    update!(pipeline: pipeline)
  end

  def merge!
    MergeRequests::MergeService.new(project, user).execute(merge_request)

    raise MergeRequests::MergeService::MergeError unless merge_request.merged?
  end

  private

  def processable
    unless project.merge_trains_enabled?
      self.errors.add(:project, 'disables merge train')
    end

    unless merge_request.can_be_merged_by?(user)
      self.errors.add(:user, 'does not have permission')
    end

    unless merge_request.mergeable?(skip_ci_check: true)
      self.errors.add(:merge_request, 'is not mergeable')
    end

    if merge_request.for_fork?
      self.errors.add(:merge_request, 'is a fork merge request')
    end

    if pipeline && !pipeline.latest_merge_request_pipeline?
      self.errors.add(:pipeline, 'is not the latest merge request pipeline')
    end
  end

  def unsafe_process(merge_request)
    merge_request = first_in_train(merge_request)
    merge_train = merge_request&.merge_train

    return unless merge_request && merge_train

    merge_train.ensure_pipeline!
    merge_train.validate!
    merge_train.merge! if merge_train.pipeline.complete?
  rescue
    merge_request.get_off_train!
  end
end
