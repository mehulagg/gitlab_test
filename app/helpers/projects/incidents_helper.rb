# frozen_string_literal: true

module Projects::IncidentsHelper
  def incidents_data(project)
    {
      'project-path' => project.full_path
    }
  end

  def incident_detail_data(project, incident_id)
    {
      'incident-id' => incident_id,
      'project-path' => project.full_path
    }
  end
end
