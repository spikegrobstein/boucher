require 'term/ansicolor'

module Boucher
  class CLI
    include Term::ANSIColor

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
#{ dark }
    .""--.
   /      "'-.._______________
  :  (_)                      !------------.
  !                           ! O    O    O )
  !                           !------------'
  !                           |#{ reset }   _                 _#{ dark }
  |                           |#{ reset }  | |__  ___ _  _ __| |_  ___ _ _#{ dark }
  |._________________________.|#{ reset }  | '_ \\/ _ \\ || / _| ' \\/ -_) '_| #{ dark }
  '___________________________'#{ reset }  |_.__/\\___/\\_,_\\__|_||_\\___|_|#{ dark }

===================================================================
#{ reset }
      SPLASH
    end

  end
end
