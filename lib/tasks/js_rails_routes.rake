
# Global config options are set in config/initializers/js_routes.rb
# Parameter options overide global options

# Note: JsRoutes only initilized in dev/test rails ENV

namespace :javascript do
    desc "Generate js files that contains url route helpers"
    task routes: :environment do
      require "js-routes"
  
      # Peek Routes
      JsRoutes.generate!(
        'app/assets/javascripts/routes/peek_routes.js', 
        namespace: "PeekRoutes", 
        include: [/peek/]
      )

      # Project Security Routes
      JsRoutes.generate!(
        'app/assets/javascripts/routes/project_security_routes.js',
         namespace: "ProjectSecurityRoutes", 
         include: [/vulnerability/, /vulnerabilities/]
      )

      puts <<~MSG
      All done. Please commit the changes to `app/assets/javascripts/routes/`.
      MSG
    end
end