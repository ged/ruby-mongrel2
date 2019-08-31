# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/config'

require 'mongrel2/cli' unless defined?( Mongrel2::CLI )


# Mongrel2 settings command
module Mongrel2::CLI::SettingsCommand
	extend Mongrel2::CLI::Subcommand


	desc "Show the 'advanced' server settings."
	command :settings do |settingscmd|

		settingscmd.action do |globals, options, args|
			prompt.say( hl.headline "Advanced Server Settings" )
			Mongrel2::Config.settings.each do |key,val|
				prompt.say( "%s %s" % [ hl.key("#{key}:"), val] )
			end
		end

	end

end # module Mongrel2::CLI::SettingsCommand
