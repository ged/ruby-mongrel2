# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 hosts command
module Mongrel2::CLI::HostsCommand
	extend Mongrel2::CLI::Subcommand

	desc "Lists the hosts in a server, or in all servers if none is specified."
	arg :SERVERNAME, :optional
	command :hosts do |hostscmd|

		hostscmd.action do |globals, options, args|
			servername = args.shift

			# Start with all servers, then narrow it down if they specified a server name.
			servers = Mongrel2::Config::Server.dataset
			servers = servers.filter( name: servername ) if servername


			# Output a section for each server
			servers.each do |server|
				hosts_table = TTY::Table.new( header: ['Id', 'Name', 'Matching'] )

				prompt.say( hl.header %{HOSTS for server %s:} % [hl.key(server.name)] )
				server.hosts.each do |host|
					hosts_table << [
						host.id,
						host.name,
						host.matching == host.name ? '*' : 'host.matching'
					]
				end

				if hosts_table.empty?
					prompt.say "No hosts."
				else
					prompt.say( hosts_table.render(:unicode) )
				end

				prompt.say( "\n" )
			end
		end

	end


end # module Mongrel2::CLI::HostsCommand
