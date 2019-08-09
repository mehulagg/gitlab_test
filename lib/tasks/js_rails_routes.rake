
namespace :js do
    desc "Generate js file that will have functions that will return restful routes/urls."
    task rails_routes: :environment do
      require "js-routes"
  
      JsRoutes.generate!

      puts <<~MSG
      All done. Please commit the changes to `app/assets/javascripts/routes.js`.
  
      MSG
    end
end