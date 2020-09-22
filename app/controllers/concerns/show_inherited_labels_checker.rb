# frozen_string_literal: true

module ShowInheritedLabelsChecker
  extend ActiveSupport::Concern

  private

  def show_inherited_labels?
    Feature.enabled?(:show_inherited_labels, @project || @group) || params[:include_ancestor_groups]
  end
end
