module Blazer
  class Engine < ::Rails::Engine
    isolate_namespace Blazer

    initializer "static assets" do |app|
      app.middleware.insert_before(::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public")
    end

    initializer "blazer" do |_app|
      Blazer.time_zone ||= Blazer.settings["time_zone"] || Time.zone
      Blazer.audit = Blazer.settings.key?("audit") ? Blazer.settings["audit"] : true
      Blazer.user_name = Blazer.settings["user_name"] if Blazer.settings["user_name"]
      Blazer.from_email = Blazer.settings["from_email"] if Blazer.settings["from_email"]
      Blazer.before_action = Blazer.settings["before_action_method"] if Blazer.settings["before_action_method"]
      Blazer.check_schedules = Blazer.settings["check_schedules"] if Blazer.settings.key?("check_schedules")
      Blazer.cache ||= Rails.cache

      Blazer.anomaly_checks = Blazer.settings["anomaly_checks"] || false
      Blazer.forecasting = Blazer.settings["forecasting"] || false
      Blazer.async = Blazer.settings["async"] || false
      Blazer.images = Blazer.settings["images"] || false
      Blazer.override_csp = Blazer.settings["override_csp"] || false
      Blazer.slack_oauth_token = Blazer.settings["slack_oauth_token"] || ENV["BLAZER_SLACK_OAUTH_TOKEN"]
      Blazer.slack_webhook_url = Blazer.settings["slack_webhook_url"] || ENV["BLAZER_SLACK_WEBHOOK_URL"]
      Blazer.mapbox_access_token = Blazer.settings["mapbox_access_token"] || ENV["MAPBOX_ACCESS_TOKEN"]
    end
  end
end
