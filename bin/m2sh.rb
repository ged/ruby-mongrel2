#!/usr/bin/env ruby

require 'loggability'
Loggability.level = :fatal

require 'mongrel2/cli'
exit Mongrel2::CLI.run( ARGV )

__END__

class Mongrel2::M2SHCommand
	extend ::Sysexits,
	       Loggability
	include Sysexits,
	        Mongrel2::Constants

	# Loggability API -- set up logging under the 'strelka' log host
	log_to :mongrel2


	# Make a HighLine color scheme
	COLOR_SCHEME = HighLine::ColorScheme.new do |scheme|
		scheme[:header]    = [ :bold, :yellow ]
		scheme[:subheader] = [ :bold, :white ]
		scheme[:key]       = [ :white ]
		scheme[:value]     = [ :bold, :white ]
		scheme[:error]     = [ :red ]
		scheme[:warning]   = [ :yellow ]
		scheme[:message]   = [ :reset ]
	end


	# Number of items to store in history by default
	DEFAULT_HISTORY_SIZE = 100


	# Class instance variables
	@command_help = Hash.new {|h,k| h[k] = { :desc => nil, :usage => ''} }
	@prompt = @option_parser = nil


	### Add a help string for the given +command+.
	def self::help( command, helpstring=nil )
		if helpstring
			@command_help[ command.to_sym ][:desc] = helpstring
		end

		return @command_help[ command.to_sym ][:desc]
	end


	### Add/fetch the +usagestring+ for +command+.
	def self::usage( command, usagestring=nil )
		if usagestring
			prefix = usagestring[ /\A(\s+)/, 1 ]
			usagestring.gsub!( /^#{prefix}/m, '' ) if prefix

			@command_help[ command.to_sym ][:usage] = usagestring
		end

		return @command_help[ command.to_sym ][:usage]
	end


	### Return the global Highline prompt object, creating it if necessary.
	def self::prompt
		unless @prompt
			@prompt = HighLine.new
			# @prompt.wrap_at = @prompt.output_cols - 3
		end

		return @prompt
	end


	### Run the utility with the given +args+.
	def self::run( args )
		HighLine.color_scheme = COLOR_SCHEME

		oparser = self.make_option_parser
		opts = Trollop.with_standard_exception_handling( oparser ) do
			oparser.parse( args )
		end

		command = oparser.leftovers.shift
		self.new( opts ).run( command, *oparser.leftovers )
		exit :ok

	rescue => err
		self.log.fatal "Oops: %s: %s" % [ err.class.name, err.message ]
		self.log.debug { '  ' + err.backtrace.join("\n  ") }

		exit :software_error
	end


	### Return a String that describes the available commands, e.g., for the 'help'
	### command.
	def self::make_command_table
		commands = self.available_commands

		# Build the command table
		col1len = commands.map( &:length ).max
		return commands.collect do |cmd|
			helptext = self.help( cmd.to_sym ) or next # no help == invisible command
			"%s  %s" % [
				self.prompt.color(cmd.rjust(col1len), :key),
				self.prompt.color(helptext, :value)
			]
		end.compact
	end


	### Return an Array of the available commands.
	def self::available_commands
		return self.public_instance_methods( false ).
			map( &:to_s ).
			grep( /_command$/ ).
			map {|methodname| methodname.sub(/_command$/, '') }.
			sort
	end


	### Create and configure a command-line option parser for the command.
	### Returns a Trollop::Parser.
	def self::make_option_parser
		unless @option_parser
			progname = File.basename( $0 )
			default_configdb = Mongrel2::DEFAULT_CONFIG_URI

			# Make a list of the log level names and the available commands
			loglevels = Loggability::LOG_LEVELS.
				sort_by {|name,lvl| lvl }.
				collect {|name,lvl| name.to_s }.
				join( ', ' )
			command_table = self.make_command_table

			@option_parser = Trollop::Parser.new do
				banner "Mongrel2 (Ruby) Shell has these commands available:"

				text ''
				command_table.each {|line| text(line) }
				text ''

				text 'Global Options'
				opt :config, "Specify the config database to use.",
					:default => DEFAULT_CONFIG_URI
				opt :sudo, "Use 'sudo' to run the mongrel2 server."
				opt :port, "Reset the server port to <i> before starting it.",
					:type => :integer
				opt :why, "Specify the reason for an action for the event log.",
					:type => :string
				text ''

				text 'Other Options:'
				opt :debug, "Turn debugging on. Also sets the --loglevel to 'debug'."
				opt :loglevel, "Set the logging level. Must be one of: #{loglevels}",
					:default => Mongrel2.logger.level.to_s
			end
		end

		return @option_parser
	end


	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Create a new instance of the command and set it up with the given
	### +options+.
	def initialize( options )
		Loggability.format_as( :color ) if $stderr.tty?
		@options = options

		if @options.debug
			$DEBUG = true
			$VERBOSE = true
			Loggability.level = Logger::DEBUG
		elsif @options.loglevel
			Loggability.level = @options.loglevel
		end

		Mongrel2::Config.configure( :configdb => @options.config )
	end


	######
	public
	######

	# The Trollop options hash the command will read its configuration from
	attr_reader :options


	# Delegate the instance #prompt method to the class method instead
	define_method( :prompt, &self.method(:prompt) )


	### Run the command with the specified +command+ and +args+.
	def run( command, *args )
		command ||= 'help'
		cmd_method = nil

		begin
			cmd_method = self.method( "#{command}_command" )
		rescue NoMethodError => err
			error "No such command"
			exit :usage
		end

		cmd_method.call( *args )
	end


	#
	# Commands
	#

	### The 'settings' command
	def settings_command( *args )
		header "Advanced Server Settings"
		Mongrel2::Config.settings.each do |key,val|
			message( %{<%= color "#{key}:", :subheader %> #{val}} )
		end
	end
	help :settings, "Show the 'advanced' server settings."
	usage :settings


	### The 'version' command
	def version_command( *args )
		message( "<%= color 'Version:', :header %> " + Mongrel2.version_string(true) )
	end
	help :version, "Prints the Ruby-Mongrel2 version."



end # class Mongrel2::M2SHCommand


Mongrel2::M2SHCommand.run( ARGV.dup )

