# -*- ruby -*-
# frozen_string_literal: true

require 'fileutils'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 load command
module Mongrel2::CLI::LoadCommand
	extend Mongrel2::CLI::Subcommand

	desc "Overwrite the config database with the values from the specified CONFIGFILE."
	long_desc <<~END_DESC
	Note: the CONFIGFILE should contain a configuration described using the
	Ruby config DSL, not a Python-ish normal one. m2sh already works perfectly
	fine for loading those.
	END_DESC
	arg :CONFIGFILE
	command :load do |loadcmd|

		loadcmd.action do |globals, options, args|
			configfile = args.shift or
				exit_now! "No configfile specified."

			runspace = Module.new
			runspace.extend( Mongrel2::Config::DSL )
			runspace.extend( FileUtils::Verbose )

			prompt.say( headline_string "Loading config from #{configfile}" )
			source = File.read( configfile )

			runspace.module_eval( source, configfile, 1 )
			Mongrel2::Config.log_action( "Loaded config from #{configfile}", globals.why )
		end

	end


end # module Mongrel2::CLI::LoadCommand

