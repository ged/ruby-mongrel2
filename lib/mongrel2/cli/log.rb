# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 log command
module Mongrel2::CLI::LogCommand
	extend Mongrel2::CLI::Subcommand

	desc "Prints the commit log."
	command :log do |logcmd|

		logcmd.action do |globals, options, args|
			prompt.say( hl.header "Log Messages" )

			Mongrel2::Config::Log.order_by( :happened_at ).each do |log|
				prompt.say( log.to_s )
			end
		end

	end


end # module Mongrel2::CLI::LogCommand
