namespace :router do
  task :router_environment do
    Bundler.require :default
    require 'router'

    @router = Router.new "http://router.cluster:8080/router"
  end

  task :register_application => :router_environment do
    backend_url = URI.parse( Plek.current.find('feedback') )

    # Plek returns a full URL (https URL in production and preview).
    # We only want to pass the host to the router.
    @router.update_application('feedback', backend_url.host)
  end

  task :register_routes => :router_environment do
    @router.create_route "feedback", "prefix", "feedback"
  end

  desc "Register feedback application and routes with the router (run this task on server in cluster)"
  task :register => [ :register_application, :register_routes ]
end
