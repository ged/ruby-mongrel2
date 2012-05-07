#!/usr/bin/ruby

require 'yajl'
require 'loggability'

require 'mongrel2/request' unless defined?( Mongrel2::Request )


# The Mongrel2 JSON Request class. Instances of this class represent a JSSocket request from
# a Mongrel2 server.
class Mongrel2::JSONRequest < Mongrel2::Request
	extend Loggability

	# Loggability API -- set up logging under the 'mongrel2' log host
	log_to :mongrel2

	# Mongrel2::Request API -- register this request type as handling 'JSON' requests
	register_request_type( self, :JSON )


	### Parse the body as JSON.
	def initialize( sender_id, conn_id, path, headers, body, raw=nil )
		super
		self.log.debug "Parsing JSON request body"
		@data = Yajl.load( body )
		self.log.debug "  body is: %p" % [ @data ]
	end


	######
	public
	######

	# The parsed request data
	attr_reader :data


	### Returns +true+ if the request is a special Mongrel2 'disconnect' 
	### notification.
	def is_disconnect?
		return true if self.data['type'] == 'disconnect'
	end

end # class Mongrel2::JSONRequest

# vim: set nosta noet ts=4 sw=4:

