# -*- ruby -*-
# frozen_string_literal: true

require 'gli'
require 'loggability'
require 'pastel'
require 'pathname'
require 'tty/prompt'
require 'tty/table'

require 'mongrel2' unless defined?( Mongrel2 )
require 'mongrel2/config'


# A tool for interacting with a Mongrel2 config database and server. This isn't
# quite a replacement for the real m2sh yet; here's what I have working so far:
#
#   [√]    load  Load a config.
#   [√]  config  Alias for load.
#   [-]   shell  Starts an interactive shell.
#   [√]  access  Prints the access log.
#   [√] servers  Lists the servers in a config database.
#   [√]   hosts  Lists the hosts in a server.
#   [√]  routes  Lists the routes in a host.
#   [√]  commit  Adds a message to the log.
#   [√]     log  Prints the commit log.
#   [√]   start  Starts a server.
#   [√]    stop  Stops a server.
#   [√]  reload  Reloads a server.
#   [√] running  Tells you what's running.
#   [-] control  Connects to the control port.
#   [√] version  Prints the Mongrel2 and m2sh version.
#   [√]    help  Get help, lists commands.
#   [-]    uuid  Prints out a randomly generated UUID.
#
# I just use 'uuidgen' to generate uuids (which is all m2sh does, as
# well), so I don't plan to implement that. The 'control' command is more-easily
# accessed via pry+Mongrel2::Control, so I'm not going to implement that, either.
# Everything else should be analagous to (or better than) the m2sh that comes with
# mongrel2. I implemented the 'shell' mode, but I found I never used it, and it
# introduced a dependency on the Termios library, so I removed it.
#
module Mongrel2::CLI
	extend Loggability,
	       GLI::App


	# Write logs to Mongrel2's logger
	log_to :mongrel2


	#
	# GLI
	#

	# Set up global[:description] and options
	program_desc 'Mongrel2 Configurator'

	# The command version
	version Mongrel2::VERSION

	# Use an OpenStruct for options instead of a Hash
	use_openstruct( true )

	# Subcommand options are independent of global[:ones]
	subcommand_option_handling :normal

	# Strict argument validation
	arguments :strict


	# Custom parameter types
	accept Array do |value|
		value.strip.split(/\s*,\s*/)
	end
	accept Pathname do |value|
		Pathname( value.strip )
	end


	# Global options
	desc 'Enable debugging output'
	switch [:d, :debug]

	desc 'Enable verbose output'
	switch [:v, :verbose]

	desc 'Set log level to LEVEL (one of %s)' % [Loggability::LOG_LEVELS.keys.join(', ')]
	arg_name :LEVEL
	flag [:l, :loglevel], must_match: Loggability::LOG_LEVELS.keys

	desc "Don't actually do anything, just show what would happen."
	switch [:n, 'dry-run']

	desc "Additional Ruby libs to require before doing anything."
	flag [:r, 'requires'], type: Array

	desc "Specify the PATH of the config database to use."
	arg_name :PATH
	flag [:config, :C], default: Mongrel2::DEFAULT_CONFIG_URI

	desc "Specify the REASON for an action for the event log."
	arg_name :REASON
	flag [:why], type: String


	#
	# GLI Event callbacks
	#

	# Set up global options
	pre do |global, command, options, args|
		self.set_logging_level( global[:l] )
		Loggability.format_with( :color ) if $stdout.tty?

		# Include a 'lib' directory if there is one
		$LOAD_PATH.unshift( 'lib' ) if File.directory?( 'lib' )

		self.require_additional_libs( global[:r] ) if global[:r]

		self.setup_pastel_aliases
		self.setup_output( global )

		Mongrel2::Config.configure( configdb: global.config ) if global.config

		true
	end


	# Write the error to the log on exceptions.
	on_error do |exception|

		case exception
		when OptionParser::ParseError, GLI::CustomExit
			msg = exception.full_message(highlight: false, order: :bottom)
			self.log.debug( msg )
		else
			msg = exception.full_message(highlight: true, order: :bottom)
			self.log.error( msg )
		end

		true
	end




	##
	# Registered subcommand modules
	singleton_class.attr_accessor :subcommand_modules


	### Overridden -- Add registered subcommands immediately before running.
	def self::run( * )
		self.add_registered_subcommands
		super
	end


	### Add the specified +mod+ule containing subcommands to the 'mongrel2' command.
	def self::register_subcommands( mod )
		self.subcommand_modules ||= []
		self.subcommand_modules.push( mod )
		mod.extend( GLI::DSL, GLI::AppSupport, Loggability, CommandUtilities )
		mod.log_to( :mongrel2 )
	end


	### Add the commands from the registered subcommand modules.
	def self::add_registered_subcommands
		self.subcommand_modules ||= []
		self.subcommand_modules.each do |mod|
			merged_commands = mod.commands.merge( self.commands )
			self.commands.update( merged_commands )
			command_objs = self.commands_declaration_order | self.commands.values
			self.commands_declaration_order.replace( command_objs )
		end
	end


	### Return the Pastel colorizer.
	###
	def self::pastel
		@pastel ||= Pastel.new( enabled: $stdout.tty? )
	end


	### Return the TTY prompt used by the command to communicate with the
	### user.
	def self::prompt
		@prompt ||= TTY::Prompt.new( output: $stderr )
	end


	### Discard the existing HighLine prompt object if one existed. Mostly useful for
	### testing.
	def self::reset_prompt
		@prompt = nil
	end


	### Set the global logging +level+ if it's defined.
	def self::set_logging_level( level=nil )
		if level
			Loggability.level = level.to_sym
		else
			Loggability.level = :fatal
		end
	end


	### Load any additional Ruby libraries given with the -r global option.
	def self::require_additional_libs( requires)
		requires.each do |path|
			path = "mongrel2/#{path}" unless path.start_with?( 'mongrel2/' )
			require( path )
		end
	end


	### Setup pastel color aliases
	###
	def self::setup_pastel_aliases
		self.pastel.alias_color( :headline, :bold, :white, :on_black )
		self.pastel.alias_color( :header, :bold, :white )
		self.pastel.alias_color( :success, :bold, :green )
		self.pastel.alias_color( :error, :bold, :red )
		self.pastel.alias_color( :key, :green )
		self.pastel.alias_color( :even_row, :bold )
		self.pastel.alias_color( :odd_row, :reset )
	end


	### Set up the output levels and globals based on the associated +global+ options.
	def self::setup_output( global )

		# Turn on Ruby debugging and/or verbosity if specified
		if global[:n]
			$DRYRUN = true
			Loggability.level = :warn
		else
			$DRYRUN = false
		end

		if global[:verbose]
			$VERBOSE = true
			Loggability.level = :info
		end

		if global[:debug]
			$DEBUG = true
			Loggability.level = :debug
		end

		if global[:loglevel]
			Loggability.level = global[:loglevel]
		end

	end


	#
	# GLI subcommands
	#


	# Convenience module for subcommand registration syntax sugar.
	module Subcommand

		### Extension callback -- register the extending object as a subcommand.
		def self::extended( mod )
			Mongrel2::CLI.log.debug "Registering subcommands from %p" % [ mod ]
			Mongrel2::CLI.register_subcommands( mod )
		end


		###############
		module_function
		###############

		### Exit with the specified +exit_code+ after printing the given +message+.
		def exit_now!( message, exit_code=1 )
			raise GLI::CustomExit.new( message, exit_code )
		end


		### Exit with a helpful +message+ and display the usage.
		def help_now!( message=nil )
			exception = OptionParser::ParseError.new( message )
			def exception.exit_code; 64; end

			raise exception
		end


		### Get the prompt (a TTY::Prompt object)
		def prompt
			return Mongrel2::CLI.prompt
		end


		### Return the global Pastel object for convenient formatting, color, etc.
		def hl
			return Mongrel2::CLI.pastel
		end


		### Return the specified +string+ in the 'headline' ANSI color.
		def headline_string( string )
			return hl.headline( string )
		end


		### Return the specified +string+ in the 'highlight' ANSI color.
		def highlight_string( string )
			return hl.highlight( string )
		end


		### Return the specified +string+ in the 'success' ANSI color.
		def success_string( string )
			return hl.success( string )
		end


		### Return the specified +string+ in the 'error' ANSI color.
		def error_string( string )
			return hl.error( string )
		end


		### Output a table with the given +header+ (an array) and +rows+
		### (an array of arrays).
		def display_table( header, rows )
			table = TTY::Table.new( header, rows )
			renderer = nil

			if hl.enabled?
				renderer = TTY::Table::Renderer::Unicode.new(
					table,
					multiline: true,
					padding: [0,1,0,1]
				)
				renderer.border.style = :dim

			else
				renderer = TTY::Table::Renderer::ASCII.new(
					table,
					multiline: true,
					padding: [0,1,0,1]
				)
			end

			puts renderer.render
		end


		### Return the count of visible (i.e., non-control) characters in the given +string+.
		def visible_chars( string )
			return string.to_s.gsub(/\e\[.*?m/, '').scan( /\P{Cntrl}/ ).size
		end


		### In dry-run mode, output the description instead of running the provided block and
		### return the +return_value+.
		### If dry-run mode is not enabled, yield to the block.
		def unless_dryrun( description, return_value=true )
			if $DRYRUN
				self.log.warn( "DRYRUN> #{description}" )
				return return_value
			else
				return yield
			end
		end
		alias_method :unless_dry_run, :unless_dryrun

	end # module Subcommand


	# Functions for common command tasks
	module CommandUtilities

		### Search the current mongrel2 config for a server matching +serverspec+ and
		### return it as a Mongrel2::Config::Server object.
		def find_server( serverspec=nil )
			server = nil
			servers = Mongrel2::Config.servers

			raise "No servers are configured." if servers.empty?

			# If there's only one configured server, just make sure if a serverspec was given
			# that it would have matched.
			if servers.length == 1
				server = servers.first if !serverspec ||
					servers.first.values.values_at( :uuid, :default_host, :name ).include?( serverspec )

			# Otherwise, require an argument and search for the desired server if there is one
			else
				raise "You must specify a server uuid/hostname/name when more " +
				      "than one server is configured." if servers.length > 1 && !serverspec

				server = servers.find {|s| s.uuid == serverspec } ||
				         servers.find {|s| s.default_host == serverspec } ||
				         servers.find {|s| s.name == serverspec }
			end

			raise "No servers match '#{serverspec}'" unless server

			return server
		end


		### Read command line history from HISTORY_FILE
		def read_history
			histfile = HISTORY_FILE.expand_path

			if histfile.exist?
				lines = histfile.readlines.collect {|line| line.chomp }
				self.log.debug "Read %d saved history commands from %s." % [ lines.length, histfile ]
				Readline::HISTORY.push( *lines )
			else
				self.log.debug "History file '%s' was empty or non-existant." % [ histfile ]
			end
		end


		### Save command line history to HISTORY_FILE
		def save_history
			histfile = HISTORY_FILE.expand_path

			lines = Readline::HISTORY.to_a.reverse.uniq.reverse
			lines = lines[ -DEFAULT_HISTORY_SIZE, DEFAULT_HISTORY_SIZE ] if
				lines.length > DEFAULT_HISTORY_SIZE

			self.log.debug "Saving %d history lines to %s." % [ lines.length, histfile ]

			histfile.open( File::WRONLY|File::CREAT|File::TRUNC ) do |ofh|
				ofh.puts( *lines )
			end
		end


		### Invoke the user's editor on the given +filename+ and return the exit code
		### from doing so.
		def edit( filename )
			editor = ENV['EDITOR'] || ENV['VISUAL'] || DEFAULT_EDITOR
			system editor, filename.to_s
			unless $?.success? || editor =~ /vim/i
				raise "Editor exited with an error status (%d)" % [ $?.exitstatus ]
			end
		end


		### Search the PATH for a mongrel2 binary, returning the absolute Pathname to it if found, and
		### outputting a warning and describing how to set ENV['MONGREL2'] if not.
		def find_mongrel2
			if ENV['MONGREL2']
				m2 = Pathname( ENV['MONGREL2'] )
				error = nil
				if !m2.file?
					error = "but it isn't a plain file."
				elsif !m2.executable?
					error = "but it isn't executable."
				end

				raise "MONGREL2 was set to #{m2}, #{error}" if error

				return m2
			else
				m2 = ENV['PATH'].split( File::PATH_SEPARATOR ).
					map {|dir| Pathname(dir) + 'mongrel2' }.
					find {|path| path.executable? }

				return m2 if m2

				raise "The 'mongrel2' binary doesn't seem to be in your PATH. Either " +
					"add the appropriate directory to your PATH or set the MONGREL2 " +
					"environment variable to the full path."
			end

		end

	end # module CommandUtilities

	### Load commands from any files in the specified directory relative to LOAD_PATHs
	def self::commands_from( subdir )
		Gem.find_latest_files( File.join(subdir, '*.rb') ).each do |rbfile|
			self.log.debug "  loading %s..." % [ rbfile ]
			require( rbfile )
		end
	end


	commands_from 'mongrel2/cli'

end # class Mongrel2::CLI
