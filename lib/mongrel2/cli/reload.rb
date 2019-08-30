# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 reload command
module Mongrel2::CLI::ReloadCommand
	extend Mongrel2::CLI::Subcommand


	desc "Reload the specified server's configuration"
	arg :SERVER
	command :reload do |reloadcmd|

		reloadcmd.action do |globals, options, args|
			server = find_server( args.shift )
			control = server.control_socket

			prompt.say( hl.header "Reloading '%s'" % [ server.name ] )
			control.reload
			control.close
			prompt.say( hl.success "done." )

			Mongrel2::Config.log_action( "Restarted server #{server}", globals.why )
		end

	end


end # module Mongrel2::CLI::ReloadCommand
