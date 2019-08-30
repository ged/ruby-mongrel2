# -*- ruby -*-
# frozen_string_literal: true

require 'pathname'
require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )
require 'mongrel2/constants'


# Mongrel2 bootstrap command
module Mongrel2::CLI::BootstrapCommand
	extend Mongrel2::CLI::Subcommand


	desc "Generate a basic config-generation script."
	arg :CONFIG_SCRIPT, :optional
	command :bootstrap do |bootstrapcmd|

		bootstrapcmd.action do |globals, options, args|
			scriptpath = Pathname( args.shift || Mongrel2::Constants::DEFAULT_CONFIG_SCRIPT )
			template   = Mongrel2::DATA_DIR + 'config.rb.in'

			# Read the config DSL template
			data = template.read
			data.gsub!( /%% PWD %%/, Dir.pwd )

			# Write it out
			prompt.say( hl.header "Writing a config-generation script to %s" % [scriptpath] )
			scriptpath.open( File::WRONLY|File::EXCL|File::CREAT, 0755, encoding: 'utf-8' ) do |fh|
				fh.print( data )
			end
			prompt.say "Done."
		end

	end


end # module Mongrel2::CLI::BootstrapCommand
