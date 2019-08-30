# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 cmdname command
module Mongrel2::CLI::CmdnameCommand
	extend Mongrel2::CLI::Subcommand

	desc ""
	command :cmdname do |cmdnamecmd|

		cmdnamecmd.action do |globals, options, args|
			prompt.say( hl.header 'A COMMAND' )
		end

	end


end # module Mongrel2::CLI::CmdnameCommand
