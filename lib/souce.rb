require "souce/version"
require 'souce/cli'
require 'souce/config'
require 'souce/blueprint'
require 'souce/capistrano'

require 'pp'

module Souce
  class << self

    attr_accessor :cap

    def bootstrap(hostname, role, &block)
      puts "That souce is DELISH!"

      Config.configure(&block)

      blueprint = Blueprint.new(hostname, role, Config)
      @cap = Capistrano.new(blueprint)

      @cap.run_recipe
    end

  end
end
