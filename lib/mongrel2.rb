# -*- ruby -*-
#encoding: utf-8

require 'loggability'
require 'cztop'

#
# A Mongrel2 connector and configuration library for Ruby.
#
# == Author/s
#
# * Michael Granger <ged@FaerieMUD.org>
# * Mahlon E. Smith <mahlon@martini.nu>
#
module Mongrel2
	extend Loggability

	# Loggability API -- set up Mongrel2 as a log host
	log_as :mongrel2


	abort "\n\n>>> Mongrel2 requires Ruby 2.2 or later. <<<\n\n" if RUBY_VERSION < '2.2.0'

	# Library version constant
	VERSION = '0.52.1'

	# Version-control revision constant
	REVISION = %q$Revision$


	require 'mongrel2/constants'
	include Mongrel2::Constants


	### Get the library version. If +include_buildnum+ is true, the version string will
	### include the VCS rev ID.
	def self::version_string( include_buildnum=false )
		vstring = "Ruby-Mongrel2 %s" % [ VERSION ]
		vstring << " (build %s)" % [ REVISION[/: ([[:xdigit:]]+)/, 1] || '0' ] if include_buildnum
		return vstring
	end


	require 'mongrel2/exceptions'
	require 'mongrel2/connection'
	require 'mongrel2/handler'
	require 'mongrel2/request'
	require 'mongrel2/httprequest'
	require 'mongrel2/jsonrequest'
	require 'mongrel2/xmlrequest'
	require 'mongrel2/websocket'
	require 'mongrel2/response'
	require 'mongrel2/control'

end # module Mongrel2


