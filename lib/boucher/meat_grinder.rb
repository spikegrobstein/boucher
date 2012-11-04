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

    # given a capistrano configuration +config+, intitialize the variables
    # and roles.
    def load_into(config, hostname)
      # host-specific config:
      config.set :node_hostname,   hostname

      host_info = self.parse_hostname(hostname)
      config.set :node_role,       self.role_for( host_info[:role] )
      config.set :node_serial,     host_info[:serial]
      config.set :node_env,        self.env_for( host_info[:environment] )

      # basic configuration:
      config.set :gateway_suffix,  self.gateway_suffix
      config.set :domain,          self.base_domain
      config.set :user,            self.user               if self.user
      config.set :cookbook_path,   self.cookbook_path      if self.cookbook_path

      # gateway server, if one is defined
      config.set :gateway,         self.gateway_server     if self.gateway_server

      # roles
      config.role :node,           hostname
      config.role :raw_node,       self.raw_system_address if self.raw_system_address
      config.role :chef_server,    self.chef_server        if self.chef_server
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
      def self.dsl_setter(name, var=nil)
        var = name if var.nil?

        define_method name do |val|
          @m.send("#{var}=", val)
        end
      end

      dsl_setter :user
      dsl_setter :raw_system_address
      dsl_setter :base_domain
      dsl_setter :gateway_suffix
      dsl_setter :nameserver_suffix
      dsl_setter :gateway_server
      dsl_setter :chef_server
      dsl_setter :cookbook_path

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
