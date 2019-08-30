# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 routes command
module Mongrel2::CLI::RoutesCommand
	extend Mongrel2::CLI::Subcommand


	desc "Show the routes under a host."
	arg :SERVERNAME, :optional
	arg :HOSTNAME, :optional
	command :routes do |routescmd|

		routescmd.action do |globals, options, args|
			servername = args.shift
			hostname = args.shift

			# Start with all hosts, then narrow it down if a server and/or host was given.
			if servername
				server = Mongrel2::Config::Server[ servername ] or
					exit_now! "No such server '#{servername}'"
				hosts = server.hosts_dataset
			else
				hosts = Mongrel2::Config::Host.dataset
			end
			hosts = hosts.where( name: hostname ) if hostname

			# Output a section for each host
			hosts.each do |host|
				header = "ROUTES for host %s/%s:" % [ hl.key(host.server.name), hl.key(host.name) ]
				prompt.say( hl.header(header)  )

				routes_table = TTY::Table.new( header: ['Id', 'Path', 'Target'] )
				host.routes.each do |route|
					routes_table << [ route.id, route.path, route.target ]
				end

				prompt.say( routes_table.render(:unicode) )
				prompt.say( "\n" )
			end
		end

	end


end # module Mongrel2::CLI::RoutesCommand
