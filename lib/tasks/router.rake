namespace :router do
  task :router_environment do
    require 'plek'
    require 'gds_api/router'

    @router_api = GdsApi::Router.new(Plek.current.find('router-api'))
    @app_id = 'feedback'
  end

  task :register_backend => :router_environment do
    @router_api.add_backend(@app_id, Plek.current.find(@app_id, :force_http => true) + "/")
  end

  task :register_routes => :router_environment do
    [
      %w(/contact prefix),
      %w(/feedback prefix),
    ].each do |path, type|
      @router_api.add_route(path, type, @app_id, :skip_commit => true)
    end

    [
      %w(/feedback /contact),
      %w(/feedback/contact /contact/govuk),
      %w(/feedback/foi /contact/foi),
      %w(/contact/dvla /contact-the-dvla),
      %w(/contact/passport-advice-line /passport-advice-line),
      %w(/contact/student-finance-england /contact-student-finance-england),
      %w(/contact/jobcentre-plus /contact-jobcentre-plus),
    ].each do |from, to|
      @router_api.add_redirect_route(from, "exact", to, "permanent", :skip_commit => true)
    end

    @router_api.commit_routes
  end

  desc "Register feedback application and routes with the router (run this task on server in cluster)"
  task :register => [ :register_backend, :register_routes ]
end
