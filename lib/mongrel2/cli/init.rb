# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 init command
module Mongrel2::CLI::InitCommand
	extend Mongrel2::CLI::Subcommand

	desc "Initialize a new empty config database."
	command :init do |initcmd|

		initcmd.action do |globals, options, args|
			if Mongrel2::Config.database_initialized?
				exit_now! "Okay, aborting." unless
					prompt.yes?( "Are you sure you want to destroy the current config? " )
			end

			prompt.say( headline_string "Initializing #{globals.config}" )
			Mongrel2::Config.init_database!
		end

	end


end # module Mongrel2::CLI::InitCommand
