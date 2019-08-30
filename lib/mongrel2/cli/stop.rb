# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 stop command
module Mongrel2::CLI::StopCommand
	extend Mongrel2::CLI::Subcommand


	desc "Stop the specified server gracefully"
	arg :SERVER
	command :stop do |stopcmd|

		stopcmd.action do |globals, options, args|
			server = find_server( args.shift )
			control = server.control_socket

			prompt.say( hl.header "Stopping '%s' gracefully." % [ server.name ] )
			control.stop
			control.close
			prompt.say( "done." )

			Mongrel2::Config.log_action( "Stopped server #{server}", globals.why )
		end

	end


end # module Mongrel2::CLI::StopCommand
