module Boucher
  class MeatGrinder

    HOSTNAME_PARSE_REGEX = /^(.+?)(\d+)\.(.+?)$/

    attr_accessor :role_map,
      :env_map,
      :raw_system_address,
      :base_domain,
      :gateway_suffix,
      :nameserver_suffix,
      :gateway_server,
      :user,
      :chef_server,
      :cookbook_path

    # This is the main processor class
    # Given a Meatfile, it will run it, process it, and return an instance
    # of itself which provides the abstractions for determining the state
    # of a node.

    def initialize
      @role_map = {}
      @env_map = {}
    end

    def process_file(meatfile_path)
      dsl = DSL.new(self)
      dsl.instance_eval( File.open(meatfile_path, 'r').read, meatfile_path)
    end

    def parse_hostname(hostname)
      unless hostname.match HOSTNAME_PARSE_REGEX
        # cannot determine the role/serial/env from the hostname
        raise "Cannot determine the role/serial/environment from #{ hostname } using #{ HOSTNAME_PARSE_REGEX.inspect }"
      end

      Hash[([:role,:serial,:environment].zip hostname.scan(HOSTNAME_PARSE_REGEX).flatten)]
    end

    # reads the env_map and returns the canonical env
    def env_for(env)
      get_map(env, @env_map)
    end

    # reads the role_map and returns the canonical role
    def role_for(role)
      get_map(role, @role_map)
    end

    # a map is just a hash of synonyms
    # given an item to be mapped, it will look it up in the map
    # and return the synonym of the item if it exists.
    # otherwise, it will return the item
    #
    # for example:
    #  map = {
    #    :app => 'application',
    #    :db => 'postgres',
    #  }
    #
    #  get_map('app', map) #=> 'application'
    #  get_map('web', map) #=> 'web'
    #
    def get_map(item, map)
      (map[item.to_sym] || item).to_s
    end

    class DSL

      attr_accessor :m # meatgrinder

      # create a DSL setter for the name name
      # if var is nil, the variable is the same as the name of the setter
      # examples:
      #
      #  create_setter :user
      #  # the same as:
      #  def user(new_user)
      #    @m.user = new_user
      #  end
      #
      #  create_setter :user, :admin_user
      #  # the same as:
      #  def user(new_user)
      #    @m.admin_user = new_user
      #  end
      def self.create_setter(name, var=nil)
        var = name if var.nil?

        define_method name do |val|
          @m.send("#{var}=", val)
        end
      end

      create_setter :user
      create_setter :raw_system_address
      create_setter :base_domain
      create_setter :gateway_suffix
      create_setter :nameserver_suffix
      create_setter :gateway_server
      create_setter :chef_server
      create_setter :cookbook_path

      def initialize(meatgrinder)
        @m = meatgrinder

      end

      def map_role(new_role, existing_role)
        @m.role_map[new_role.to_sym] = existing_role
      end

      def map_env(new_env, existing_env)
        @m.env_map[new_env.to_sym] = existing_env
      end

    end

  end
end
