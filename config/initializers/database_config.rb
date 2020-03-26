# frozen_string_literal: true

def log_pool_size(db, previous_pool_size, current_pool_size)
  log_message = ["#{db} connection pool size: #{current_pool_size}"]

  if previous_pool_size && current_pool_size != previous_pool_size
    log_message << "(changed from #{previous_pool_size} to meet min/max requirements)"
  end

  Gitlab::AppLogger.debug(log_message.join(' '))
end

def ensure_valid_pool_size(db, db_config)
  # dynamic components based on runtime concurrency and user settings
  max_threads = Gitlab::Runtime.max_threads
  configured_pool_size = db_config['pool'].to_i

  # hard lower and upper bounds for the number of connections we will pool
  max_pool_size = Gitlab::Database::MAX_POOL_SIZE
  min_pool_size = [max_threads + Gitlab::Database::POOL_HEADROOM, max_pool_size].min

  # force pool size into the defined bounds
  final_pool_size = configured_pool_size.clamp(min_pool_size, max_pool_size)

  # apply new settings
  db_config['pool'] = final_pool_size
  db.establish_connection(db_config)
  new_pool_size = db.connection_pool.size

  log_pool_size(db.name, configured_pool_size, new_pool_size)
end

main_db_config = Gitlab::Database.config || Rails.application.config.database_configuration[Rails.env]
ensure_valid_pool_size(ActiveRecord::Base, main_db_config)

Gitlab.ee do
  # We need to initialize the Geo database before
  # setting the Geo DB connection pool size.
  if File.exist?(Rails.root.join('config/database_geo.yml'))
    Rails.application.configure do
      config.geo_database = config_for(:database_geo)
    end
  end

  if Gitlab::Geo.geo_database_configured?
    ensure_valid_pool_size(Geo::TrackingBase, Rails.configuration.geo_database)
  end
end
