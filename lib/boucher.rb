require "boucher/version"
require 'boucher/cli'
require 'boucher/config'
require 'boucher/blueprint'
require 'boucher/capistrano'

require 'pp'

module Boucher
  class << self

    attr_accessor :cap

    def bootstrap(hostname, role, &block)
      puts "That boucher is DELISH!"

      Config.configure(&block)

      blueprint = Blueprint.new(hostname, role, Config)
      @cap = Capistrano.new(blueprint)

      @cap.run_recipe
    end

  end
end
