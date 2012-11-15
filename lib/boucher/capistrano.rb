require 'capistrano'
require 'capistrano/cli'

module Boucher
  class Capistrano < ::Capistrano::Configuration

    def initialize
      super

      logger.level = ::Capistrano::Logger::TRACE
      set(:password) { ::Capistrano::CLI.password_prompt }

      load File.join( File.dirname(__FILE__), 'recipe.rb' )
    end

    # pings a node with +count+ pings and a timeout of +timeout+ seconds
    # if Chef Server is being used, ping from chef_server
    # if a gateway is being used, ping from there
    # otherwise, ping from the local machine.
    def ping_node(count=1, timeout=2)
      cmd = "ping -c #{ count } -t #{ timeout } #{ fetch(:node_hostname) } 2>&1 > /dev/null"

      if using_chef_server?
        run cmd, :roles => :chef_server
      elsif fetch(:gateway, nil)
        run cmd, :hosts => gateway
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

    # determines if a node is online by calling +ping_node+
    def node_online?
      begin
        ping_node
      rescue
        return false
      end

      return true
    end

    # returns whether the role is in use by seeing if any are defined.
    def using_role?(role_name)
      find_servers(:roles => role_name).count > 0
    end

    # returns whether we are using chef_server
    def using_chef_server?
      using_role? :chef_server
    end

    # returns whether we are using raw nodes
    def using_raw_node?
      using_role? :raw_node
    end

    def run_recipe
      if !node_online?
        if using_raw_node?
          configure_node

          puts "==================================================================="
          puts "    DON'T FORGET TO UPDATE YOUR NETWORKING CONFIG IF NECESSARY"
          puts "==================================================================="

          wait_for_node_to_come_online
        else
          # if we're not using a raw node, just spit out error
          abort "Node is not online. Cannot continue. Ensure that the node is online and available and try again."
        end
      end

      if using_chef_server?
        begin
          bootstrap
        rescue ::Capistrano::CommandError
          # try again
          puts "Trying again..."
          bootstrap
        end
      else
        # we're not using chef server
        # so we just want to copy the cookbooks, build a solo.rb and chef-solo it up on the node
        upload_cookbooks
        run_chef_solo
      end
    end

  end
end
