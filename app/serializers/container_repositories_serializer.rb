# frozen_string_literal: true

class ContainerRepositoriesSerializer < BaseSerializer
  entity ContainerRepositoryEntity

  def with_pagination(request, response)
    tap { @paginator = Gitlab::Serializer::Pagination.new(request, response) }
  end

  def paginated?
    @paginator.present?
  end

  def represent_read_only(resource)
    represent(resource, except: [:destroy_path])
  end

  def represent(resource, opts = {})
    resource = @paginator.paginate(resource) if paginated?

    super(resource, opts)
  end
end
