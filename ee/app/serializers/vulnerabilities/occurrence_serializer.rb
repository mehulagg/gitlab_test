# frozen_string_literal: true

class Vulnerabilities::OccurrenceSerializer < BaseSerializer
  include WithPagination

  entity Vulnerabilities::OccurrenceEntity

  def represent(resource, opts = {})
    if paginated?
      resource = paginator.paginate(resource)
    end

    if opts[:hide_dismissed] == true
      resource = resource.reject(&:dismissed?)
    end

    if opts.delete(:preload)
      resource = Gitlab::Vulnerabilities::OccurrencesPreloader.preload!(resource)
    end

    super(resource, opts)
  end
end
