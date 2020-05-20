# frozen_string_literal: true

class ProjectServicesWithInheritance
  SCOPES_SETTINGS_MAP = {
    push_hooks: :push_events,
    issue_hooks: :issues_events,
    merge_request_hooks: :merge_requests_events,
    tag_push_hooks: :tag_push_events,
    wiki_page_hooks: :wiki_page_events,
    pipeline_hooks: :pipeline_events,
    confidential_issue_hooks: :confidential_issues_events,
    confidential_note_hooks: :confidential_note_events
  }.freeze

  def initialize(project)
    @project = project
  end

  def all
    [].tap do |result|
      all_with_ancestors.group_by { |service| service.type }.each do |_, services|
        properties = {}
        push_events = false
        issues_events = false
        services.each do |service|
          properties = properties.merge(service.properties) { |_, oldval, newval| !newval.nil? ? newval : oldval }

          # TODO do this for all types of events where NULL is allowed
          issues_events = service.issues_events unless service.issues_events.nil?
          push_events = service.push_events unless service.push_events.nil?
        end
        services.last.properties = properties
        services.last.issues_events = issues_events
        services.last.push_events = push_events
        result << services.last
      end
    end
  end

  def all_with_ancestors
    Service.find_by_sql(services_with_parents_sql)
  end

  # rubocop:disable GitlabSecurity/PublicSend
  def hooks(scope)
    event = SCOPES_SETTINGS_MAP[scope.to_sym]
    return @project.services.public_send(scope) unless event

    all.select { |service| service.activated? && service.public_send(event) }
  end
  # rubocop:enable GitlabSecurity/PublicSend

  private

  def services_with_parents_sql
    "WITH recursive recursive_services AS ("\
      "SELECT services.*, NULLIF(parent.id, services.id) AS parent_service_id, 1 AS level "\
        "FROM services "\
        "LEFT JOIN projects project ON services.project_id = project.id "\
        "LEFT JOIN namespaces group_namespace ON project.namespace_id = group_namespace.id "\
        "LEFT JOIN services parent ON services.type = parent.type AND CASE WHEN group_namespace.type IS NULL THEN -1 ELSE group_namespace.id END = parent.group_id "\
        "WHERE services.project_id = #{@project.id} "\
      "UNION ALL "\
      "SELECT services.*, NULLIF(COALESCE(parent.id,instance.id), services.id) AS parent_service_id, level + 1 as level "\
        "FROM recursive_services "\
        "JOIN services ON services.id = recursive_services.parent_service_id "\
        "LEFT JOIN namespaces group_namespace ON services.group_id = group_namespace.id "\
        "LEFT JOIN services parent ON services.type = parent.type AND parent.group_id = group_namespace.parent_id "\
        "LEFT JOIN services instance ON services.type = instance.type AND instance.instance IS TRUE"\
    ")SELECT * FROM recursive_services ORDER BY level DESC"\
    # TODO: Add a spec for ORDER BY level DESC
    # TODO: Insert ID in an SQL safe way
  end
end
