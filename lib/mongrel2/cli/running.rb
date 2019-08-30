# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 running command
module Mongrel2::CLI::RunningCommand
	extend Mongrel2::CLI::Subcommand


	desc "Show the status of a server."
	arg :SERVER
	command :running do |runningcmd|

		runningcmd.action do |globals, options, args|
			server = find_server( args.shift )
			pidfile = server.pid_file_path

			prompt.say( hl.header "Checking the status of the '%s' server." % [ server.name ] )
			unless pidfile.exist?
				prompt.say( hl.error "Not running: PID file (%s) doesn't exist." % [ pidfile ] )
				exit
			end

			pid = Integer( pidfile.read )
			begin
				Process.kill( 0, pid )
			rescue Errno::ESRCH
				prompt.say( hl.error "  mongrel2 at PID %d is NOT running" % [ pid ] )
				exit
			rescue => err
				prompt.say( hl.error "  %p while signalling PID %d: %s" % [ err.class, pid, err.message ] )
			end

			prompt.say( hl.success "  mongrel2 at PID %d is running." % [ pid ] )
		end

	end


end # module Mongrel2::CLI::RunningCommand
