unless Rails.env.production?
    JsRoutes.setup do |config|
        ## Global js-routes config
    
        # config.<OPTION> = <OPTION_VALUE> 
    
        # exclude - Array of regexps to exclude from routes.
        # Default: []
        #
        # The regexp applies only to the name before the _path suffix, eg: you want to match exactly settings_path, the regexp should be /^settings$/
        
    
        # include - Array of regexps to include in routes.
        # Default: []
        #
        # The regexp applies only to the name before the _path suffix, eg: you want to match exactly settings_path, the regexp should be /^settings$/
        
    
        # namespace - global object used to access routes.
        # Default: Routes
        #
        # Supports nested namespace like MyProject.routes
        
    
        # camel_case - Generate camel case route names.
        # Default: false
        
    
        # url_links - Generate *_url helpers (in addition to the default *_path helpers).
        # Default: false
        #
        # Note: generated URLs will first use the protocol, host, and port options specified in the route definition. Otherwise, the URL will be based on the option specified in the default_url_options config. If no default option has been set, then the URL will fallback to the current URL based on window.location.
        
    
        # compact - Remove _path suffix in path routes(*_url routes stay untouched if they were enabled)
        # Default: false
        #
        # Sample route call when option is set to true: Routes.users() => /users
        
    
        # application - a key to specify which rails engine you want to generate routes too.
        # Default: Rails.application
        #
        # This option allows to only generate routes for a specific rails engine, that is mounted into routes instead of all Rails app routes
    
    
        # default_url_options - default parameters used when generating URLs
        # Default: {}
        # Example: {format: "json", trailing_slash: true, protocol: "https", subdomain: "api", host: "example.com", port: 3000}
        #
        # Option is configurable at JS level with Routes.configure()
    
    
        # prefix - String representing a url path to prepend to all paths.
        # Default: Rails.application.config.relative_url_root
        # Example: http://yourdomain.com. This will cause route helpers to generate full path only.
        #
        # Option is configurable at JS level with Routes.configure()
        
    
        # serializer - a JS function that serializes a Javascript Hash object into URL paramters like {a: 1, b: 2} => "a=1&b=2".
        # Default: nil. Uses built-in serializer compatible with Rails
        # Example: jQuery.param - use jQuery serializer algorithm. You can attach serialize function from your favorite AJAX framework.
        # Example: function (object) { ... } - use completely custom serializer of your application.
        #
        # Option is configurable at JS level with Routes.configure()
    
        
        # special_options_key - a special key that helps JsRoutes to destinguish serialized model from options hash
        # Default: _options
    
        # This option exists because JS does not provide a difference between an object and a hash
        # Option is configurable at JS level with Routes.configure()
    end
end
