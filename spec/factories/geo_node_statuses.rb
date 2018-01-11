FactoryBot.define do
  factory :geo_node_status do
    sequence(:id)
    geo_node
    storage_shards { StorageShard.all }

    trait :healthy do
      health nil
      attachments_count 329
      attachments_failed_count 13
      attachments_synced_count 141
      lfs_objects_count 256
      lfs_objects_failed_count 12
      lfs_objects_synced_count 123
      job_artifacts_count 580
      job_artifacts_failed_count 3
      job_artifacts_synced_count 577
      repositories_count 10
      repositories_synced_count 5
      repositories_failed_count 0
      wikis_count 9
      wikis_synced_count 4
      wikis_failed_count 1
      last_event_id 2
      last_event_timestamp { Time.now.to_i }
      cursor_last_event_id 1
      cursor_last_event_timestamp { Time.now.to_i }
      last_successful_status_check_timestamp { Time.now.beginning_of_day }
    end

    trait :unhealthy do
      health "Could not connect to Geo node - HTTP Status Code: 401 Unauthorized\nTest"
    end
  end
end
