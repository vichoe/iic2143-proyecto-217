require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do |_worker|
      SimpleCov.result
    end

    fixtures :all

    def with_public_profiles(value)
      original = Rails.configuration.x.public_profiles
      Rails.configuration.x.public_profiles = value
      yield
    ensure
      Rails.configuration.x.public_profiles = original
    end
  end
end