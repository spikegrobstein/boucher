module Boucher
  class Config

    attr_accessor :role_map,
      :env_map,
      :raw_system_address,
      :base_domain,
      :gateway_suffix,
      :nameserver_suffix,
      :gateway_server,
      :user,
      :chef_server

    REQUIRED_FIELDS = [
      :raw_system_address,
      :base_domain,
      :gateway_suffix,
      :nameserver_suffix,
      :user,
      :chef_server
    ]


    def initialize(*args, &block)
      file = args.first

      # raise an error unless we get one of file and block.
      raise "Initializing incorrectly. Filepath or block. not both." if file.nil? != block_given?

      dsl = DSL.new

      if block_given?
        dsl.instance_eval(&block)
      else
        dsl.instance_eval(File.open(file, 'r').read)
      end

      @role_map = dsl.state[:role_map]
      @env_map = dsl.state[:env_map]
      @raw_system_address = dsl.state[:raw_system_address]
      @base_domain = dsl.state[:base_domain]
      @gateway_suffix = dsl.state[:gateway_suffix]
      @nameserver_suffix = dsl.state[:nameserver_suffix]
      @gateway_server = dsl.state[:gateway_server]
      @user = dsl.state[:user]
      @chef_server = dsl.state[:chef_server]
    end

    # reads the env_map and returns the canonical env
    def env_for(env)
      get_map(env, env_map)
    end

    # reads the role_map and returns the canonical role
    def role_for(role)
      get_map(role, role_map)
    end

    # a map is just a hash of synonyms
    # given an item to be mapped, it will look it up in the map
    # and return the synonym of the item if it exists.
    # otherwise, it will return the item
    #
    # for example:
    #   map = {
    #       :app => 'application',
    #       :db => 'postgres',
    #   }
    #  get_map('app', map) => 'application'
    #  get_map('web', map) => 'web'
    #
    def get_map(item, map)
      (map[item.to_sym] || item).to_s
    end

    # returns true if all required fields are set
    # required fields are all except the env and role maps.
    def valid?
      REQUIRED_FIELDS.each do |f|
        return false if self.send(f).nil?
      end
    end

    class DSL
      attr_accessor :state

      def initialize
        @state = {}
        @state[:role_map] = {}
        @state[:env_map] = {}
      end

      def user(user)
        @state[:user] = user
      end

      def map_role(new_role, existing_role)
        @state[:role_map][new_role.to_sym] = existing_role
      end

      def map_env(new_env, existing_env)
        @state[:env_map][new_env.to_sym] = existing_env
      end

      def raw_system_address(addr)
        @state[:raw_system_address] = addr
      end

      def base_domain(base_domain)
        @state[:base_domain] = base_domain
      end

      def gateway_suffix(suffix)
        @state[:gateway_suffix] = suffix
      end

      def nameserver_suffix(suffix)
        @state[:nameserver_suffix] = suffix
      end

      def gateway_server(server)
        @state[:gateway_server] = server
      end

      def chef_server(server)
        @state[:chef_server] = server
      end
    end


  end
end
