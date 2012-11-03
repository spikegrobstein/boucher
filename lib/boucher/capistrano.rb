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

        role :raw_node, blueprint[:raw_system_address] if blueprint[:raw_system_address]
        role :node, blueprint[:hostname]
        role :chef_server, blueprint[:chef_server] if blueprint[:chef_server]

        set :user, blueprint[:user]
      end

      load File.join(File.dirname(__FILE__), 'recipe.rb')
    end

    def run_recipe
      load do
        def ping_node
          cmd = "ping -c 1 -t 2 #{ hostname } 2>&1 > /dev/null"

          if find_servers(:roles => :chef_server).count > 0
            run cmd, :roles => :chef_server
          else
            run_locally cmd
          end
        end

        # stolen from Capistrano's deploy recipe
        # logs the command then executes it locally.
        # returns the command output as a string
        def run_locally(cmd)
          logger.trace "executing locally: #{cmd.inspect}" if logger
          output_on_stdout = nil
          elapsed = Benchmark.realtime do
            output_on_stdout = `#{cmd}`
          end
          if $?.to_i > 0 # $? is command exit code (posix style)
            raise ::Capistrano::LocalArgumentError, "Command #{cmd} returned status code #{$?}"
          end
          logger.trace "command finished in #{(elapsed * 1000).round}ms" if logger
          output_on_stdout
        end

        def node_online?
          begin
            ping_node
          rescue
            return false
          end

          return true
        end


        unless node_online?
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
