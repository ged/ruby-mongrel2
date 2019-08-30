# -*- ruby -*-
# frozen_string_literal: true

require 'shellwords'
require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 start command
module Mongrel2::CLI::StartCommand
	extend Mongrel2::CLI::Subcommand


	desc "Starts a server."
	long_desc <<~END_USAGE
	[SERVER]
	If not specified, SERVER is assumed to be the only server entry in the
	current config. If there are more than one, you must specify a SERVER.

	The SERVER can be a uuid, hostname, or server name, and are searched for
	in that order.
	END_USAGE
	arg :SERVER, :optional
	command :start do |startcmd|

		startcmd.switch [:sudo, :s], desc: "Start the server with `sudo`"

		startcmd.arg_name :PORT
		startcmd.flag [:port, :p], desc: "Reset the configured PORT to bind to",
			type: Integer

		startcmd.action do |globals, options, args|
			server = find_server( args.shift )
			mongrel2 = find_mongrel2()

			if options.port
				prompt.say "Resetting %s server's port to %d" % [ server.name, options.port ]
				server.port = options.port
				server.save
			end

			cmd = [ mongrel2.to_s, Mongrel2::Config.dbname.to_s, server.uuid ]
			cmd.unshift( 'sudo' ) if options.sudo

			url = "http%s://%s:%d" % [
				server.use_ssl? ? 's' : '',
				server.bind_addr,
				server.port,
			]

			# Change into the server's chroot directory so paths line up whether or not
			# it's started as root

			prompt.say( hl.header '*' * 70 )
			prompt.say( hl.headline "Starting mongrel2 at: %s" % [ hl.key(url) ] )
			prompt.say( hl.header '*' * 70 )

			if server.chroot && server.chroot != '' && server.chroot != '.'
				Dir.chdir( server.chroot )
				prompt.say "  changed PWD to: #{Dir.pwd}"
			end

			Mongrel2::Config.log_action( "Starting server: #{server}", options.why )
			self.log.debug "  command is: #{Shellwords.shelljoin(cmd)}"
			exec( *cmd )
		end

	end


end # module Mongrel2::CLI::StartCommand
