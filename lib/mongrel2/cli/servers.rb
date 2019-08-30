# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 servers command
module Mongrel2::CLI::ServersCommand
	extend Mongrel2::CLI::Subcommand

	desc "Lists the servers in a config database."
	command :servers do |serverscmd|

		serverscmd.action do |globals, options, args|
			prompt.say( hl.header 'SERVERS:' )

			table = TTY::Table.new( header: ['Name', 'Default Host', 'Identifier'] )
			Mongrel2::Config.servers.each do |server|
				table << [
					hl.key( server.name ),
					server.default_host,
					server.uuid,
				]
			end

			prompt.say( table.render(:unicode) )
		end

	end


end # module Mongrel2::CLI::ServersCommand
