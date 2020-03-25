# frozen_string_literal: true

def log_pool_size(db, previous_pool_size, current_pool_size)
  log_message = ["#{db} connection pool size: #{current_pool_size}"]

  if previous_pool_size && current_pool_size != previous_pool_size
    log_message << "(changed from #{previous_pool_size} to meet requirements)"
  end

  Gitlab::AppLogger.debug(log_message.join(' '))
end

Gitlab.ee do
  # We need to initialize the Geo database before
  # setting the Geo DB connection pool size.
  if File.exist?(Rails.root.join('config/database_geo.yml'))
    Rails.application.configure do
      config.geo_database = config_for(:database_geo)
    end
  end
end

# dynamic components based on runtime concurrency and user settings
max_threads = Gitlab::Runtime.max_threads
db_config = Gitlab::Database.config ||
    Rails.application.config.database_configuration[Rails.env]
configured_pool_size = db_config['pool'].to_i

# hard lower and upper bounds to the number of connections we will pool
max_pool_size = Gitlab::Database::MAX_POOL_SIZE
min_pool_size = [max_threads + Gitlab::Database::POOL_HEADROOM, max_pool_size].min

# force pool size into the defined bounds
final_pool_size = configured_pool_size.clamp(min_pool_size, max_pool_size)

# enforce new settings
db_config['pool'] = final_pool_size
ActiveRecord::Base.establish_connection(db_config)
new_pool_size = ActiveRecord::Base.connection.pool.size

log_pool_size('DB', configured_pool_size, new_pool_size)

Gitlab.ee do
  if Gitlab::Runtime.sidekiq? && Gitlab::Geo.geo_database_configured?
    previous_geo_db_pool_size = Rails.configuration.geo_database['pool']
    Rails.configuration.geo_database['pool'] = max_threads
    Geo::TrackingBase.establish_connection(Rails.configuration.geo_database)
    current_geo_db_pool_size = Geo::TrackingBase.connection_pool.size
    log_pool_size('Geo DB', previous_geo_db_pool_size, current_geo_db_pool_size)
  end
end
