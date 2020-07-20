# frozen_string_literal: true

class BranchesFinder < GitRefsFinder
  def initialize(repository, params = {})
    super(repository, params)
  end

  def execute(gitaly_pagination: false)
    branches =
      if gitaly_pagination && names.blank? && search.blank?
        repository.branches_sorted_by(sort, pagination_params)
      else
        branches = repository.branches_sorted_by(sort)
        branches = by_search(branches)
        by_names(branches)
      end

    sort_default_first(branches)
  end

  private

  def project
    @project ||= repository.project
  end

  def sort_default_first(branches)
    return branches unless project.show_default_branch_first?
    return branches unless project.default_branch.present?

    branches.sort do |a, b|
      if a.name == project.default_branch
        -1
      elsif b.name == project.default_branch
        1
      else
        0
      end
    end
  end

  def names
    @params[:names].presence
  end

  def per_page
    @params[:per_page].presence
  end

  def page_token
    "#{Gitlab::Git::BRANCH_REF_PREFIX}#{@params[:page_token]}" if @params[:page_token]
  end

  def pagination_params
    { limit: per_page, page_token: page_token }
  end

  def by_names(branches)
    return branches unless names

    branch_names = names.to_set
    branches.select do |branch|
      branch_names.include?(branch.name)
    end
  end
end
