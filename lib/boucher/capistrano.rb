require 'capistrano'
require 'capistrano/cli'

module Boucher
  class Capistrano < ::Capistrano::Configuration

    def initialize(blueprint)
      super

      logger.level = ::Capistrano::Logger::TRACE
      set(:password) { ::Capistrano::CLI.password_prompt }
      #load "standard"

      load do
        set :hostname, blueprint[:hostname]
        set :serial, blueprint[:serial]
        set :chef_role, blueprint[:role]
        set :gateway_suffix, blueprint[:gateway_suffix]
        set :chef_env, blueprint[:environment]
        set :domain, blueprint[:domain]

        set :gateway, blueprint[:gateway] unless blueprint[:gateway].nil?

        role :raw_node, blueprint[:system_address]
        role :node, blueprint[:hostname]
        role :chef_server, blueprint[:chef_server]

        set :user, blueprint[:user]
      end

      load File.join(File.dirname(__FILE__), 'recipe')
    end

    def run_recipe
      load do
        if ENV['ONLY_BOOTSTRAP'].nil?
          configure_node

          puts "==================================================================="
          puts "    DON'T FORGET TO UPDATE YOUR NETWORKING CONFIG IF NECESSARY"
          puts "==================================================================="

          wait_for_node_to_come_online
        end

        begin
          bootstrap
        rescue ::Capistrano::CommandError
          # try again
          puts "Trying again..."
          bootstrap
        end
      end
    end

  end
end
