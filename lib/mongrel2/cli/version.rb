# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 version command
module Mongrel2::CLI::VersionCommand
	extend Mongrel2::CLI::Subcommand

	desc "Show the Ruby-Mongrel2 version"
	command :version do |versioncmd|

		versioncmd.action do |globals, options, args|
			prompt.say( Mongrel2.version_string(true) )
		end

	end

end # module Mongrel2::CLI::VersionCommand
