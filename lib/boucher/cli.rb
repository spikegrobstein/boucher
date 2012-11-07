module Boucher
  class CLI

    attr_accessor :hostname
    attr_accessor :meatfile
    attr_accessor :meatgrinder

    def initialize(*args)
      show_splash
      @hostname = args.first
      @meatfile = Meatfile::hunt_for_meat
      @meatgrinder = MeatGrinder.new
      @meatgrinder.process_file(@meatfile)

      #@blueprint = Blueprint.new(@hostname, 'role', @config)
    end

    # FIXME a lot of this shit should be in Boucher::Base or something
    # not in the CLI portion. sheesh.
    def run!
      @cap = Boucher::Capistrano.new

      @meatgrinder.load_into(@cap, @hostname)

      @cap.run_recipe
    end

    def show_splash
      $stderr.puts <<-SPLASH

    .""--.
   /      "'-.._______________
  :  (_)                      !------------.
  !                           ! O    O    O )
  !                           !------------'
  !                           |   _                 _
  |                           |  | |__  ___ _  _ __| |_  ___ _ _
  |._________________________.|  | '_ \\/ _ \\ || / _| ' \\/ -_) '_|
  '___________________________'  |_.__/\\___/\\_,_\\__|_||_\\___|_|

===================================================================

      SPLASH
    end

  end
end
