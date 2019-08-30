# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 quickstart command
module Mongrel2::CLI::QuickstartCommand
	extend Mongrel2::CLI::Subcommand


	desc "Set up a basic mongrel2 server and run it."
	command :quickstart do |quickstartcmd|

		quickstartcmd.action do |globals, options, args|
			idx_template = Mongrel2::DATA_DIR + 'index.html.in'
			configfile = 'config.rb'

			header "Quickstart!"
			self.bootstrap_command( configfile )
			edit( configfile )
			self.load_command( configfile )

			# Now load the new config DB and fetch the configured server
			host = Mongrel2::Config.servers.first.hosts.first
			hello_route = host.routes_dataset.filter( target_type: 'handler' ).first

			# Read the index page template
			data = idx_template.read
			data.gsub!( /%% VERSION %%/, Mongrel2.version_string(true) )
			data.gsub!( /%% HELLOWORLD_SEND_SPEC %%/, hello_route.target.send_spec )
			data.gsub!( /%% HELLOWORLD_RECV_SPEC %%/, hello_route.target.recv_spec )
			data.gsub!( /%% HELLOWORLD_URI %%/, hello_route.path[ /([^\(]*)/ ] )

			# Write it out to the public directory
			header "Writing an index file to public/index.html"
			Dir.mkdir( 'public' ) unless File.directory?( 'public' )
			File.open( 'public/index.html', File::WRONLY|File::EXCL|File::CREAT, 0755,
			           encoding: 'utf-8' ) do |fh|
				fh.print( data )
			end
			message "Done."

			self.start_command()
		end

	end


end # module Mongrel2::CLI::QuickstartCommand
