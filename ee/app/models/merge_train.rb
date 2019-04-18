# frozen_string_literal: true

class MergeTrain < ApplicationRecord
  include AtomicInternalId

  belongs_to :merge_request
  belongs_to :project

  has_internal_id :iid, scope: :project, init: ->(s) do
    s.project.merge_trains.maximum(:iid)
  end

  validates :merge_request_id, uniqueness: { scope: :project_id }

  scope :same_targets, -> (project, target_branch) { where(project: project, target_branch: target_branch) }

  def prev
    MergeRequest.where(id:
      MergeTrain.same_targets(project, target_branch)
                .where('iid < ?', iid)
                .order(iid: :desc)
                .limit(1)
                .select(:merge_request_id)).take
  end

  def next
    MergeRequest.where(id:
      MergeTrain.same_targets(project, target_branch)
                .where('iid > ?', iid)
                .order(iid: :asc)
                .limit(1)
                .select(:merge_request_id)).take
  end

  def first
    MergeRequest.where(id:
      MergeTrain.same_targets(project, target_branch)
                .order(iid: :asc)
                .limit(1)
                .select(:merge_request_id)).take
  end

  def after_all
    MergeRequest.where(id:
      MergeTrain.same_targets(project, target_branch)
                .where('iid > ?', iid)
                .order(iid: :asc)
                .select(:merge_request_id)).all
  end

  def first?
    prev.nil?
  end
end
