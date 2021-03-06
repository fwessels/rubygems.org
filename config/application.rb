require File.expand_path('../boot', __FILE__)

require 'rails'
require 'action_controller/railtie'

unless Rails.env.maintenance?
  require 'rails/test_unit/railtie'
  require 'action_mailer/railtie'
  require 'active_record/railtie'
end

Bundler.require(:default, Rails.env) if defined?(Bundler)

$rubygems_config = YAML.load_file("config/rubygems.yml")[Rails.env].symbolize_keys
HOST             = $rubygems_config[:host]

# DO NOT EDIT THIS LINE DIRECTLY
# Instead, run: bundle exec rake gemcutter:rubygems:update VERSION=[version number] RAILS_ENV=[staging|production] S3_KEY=[key] S3_SECRET=[secret]
RUBYGEMS_VERSION = "2.0.3"

module Gemcutter
  class Application < Rails::Application
    config.time_zone = "UTC"
    config.encoding  = "utf-8"

    config.middleware.use "Hostess"
    config.middleware.insert_after "Hostess", "Redirector" if $rubygems_config[:redirector] && ENV["LOCAL"].nil?

    unless Rails.env.maintenance?
      config.action_mailer.default_url_options  = { :host => HOST }
      config.action_mailer.delivery_method      = $rubygems_config[:delivery_method]
      config.active_record.include_root_in_json = false
    end

    config.after_initialize do
      Hostess.local = $rubygems_config[:local_storage]
    end

    config.plugins = [:dynamic_form]
    config.plugins << :heroku_asset_cacher if $rubygems_config[:asset_cacher]

    config.autoload_paths << "./app/jobs"
  end
end
