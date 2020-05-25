require 'hypernova'

Hypernova.configure do |config|
  config.host = "localhost"
  config.port = 3030
  config.open_timeout = 5
  config.timeout = 5
end
