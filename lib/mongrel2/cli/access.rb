# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 access command
module Mongrel2::CLI::AccessCommand
	extend Mongrel2::CLI::Subcommand

	desc "Dump the access log. The LOGFILE defaults to logs/access.log"
	arg :LOGFILE, :optional
	command :access do |accesscmd|

		accesscmd.action do |globals, options, args|
			logfile = args.shift || 'logs/access.log'

			IO.foreach( logfile ) do |line|
				row, _ = TNetstring.parse( line )
				message %{[%4$d] %2$s:%3$d %1$s "%5$s %6$s %7$s" %8$03d %9$d} % row
			end
		end

	end


end # module Mongrel2::CLI::AccessCommand
