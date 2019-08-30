# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 commit command
module Mongrel2::CLI::CommitCommand
	extend Mongrel2::CLI::Subcommand

	desc "Add a message to the commit log."
	arg :WHAT, :optional
	arg :WHERE, :optional
	arg :WHY, :optional
	arg :HOW, :optional
	command :commit do |commitcmd|

		commitcmd.action do |globals, options, args|
			what, where, why, how = *args
			what ||= '- mark -'
			why ||= globals.why

			log = Mongrel2::Config::Log.log_action( what, where, why, how )

			prompt.say( hl.header "Okay, logged." )
			prompt.say( log.to_s )
		end

	end


end # module Mongrel2::CLI::CommitCommand
