# -*- ruby -*-
# frozen_string_literal: true

require 'stringio'
require 'tnetstring'
require 'yajl'
require 'loggability'

require 'mongrel2' unless defined?( Mongrel2 )


# The Mongrel2 Response base class.
class Mongrel2::Response
	extend Loggability

	# Loggability API -- set up logging under the 'mongrel2' log host
	log_to :mongrel2

	# The default number of bytes of the response body to send to the mongrel2
	# server at a time.
	DEFAULT_CHUNKSIZE = 1024 * 512


	### Create a response to the specified +request+ and return it.
	def self::from_request( request )
		self.log.debug "Creating a %p to request %p" % [ self, request ]
		response = new( request.sender_id, request.conn_id )
		response.request = request

		return response
	end


	### Create a new Response object for the specified +sender_id+, +conn_id+, and +body+.
	def initialize( sender_id, conn_id, body='' )
		body = StringIO.new( body.dup, 'a+' ) unless body.respond_to?( :read )

		@sender_id             = sender_id
		@conn_id               = conn_id
		@body                  = body
		@request               = nil
		@chunksize             = DEFAULT_CHUNKSIZE
		@extended_reply_filter = nil
		@extended_reply_data   = []
	end


	######
	public
	######

	# The response's UUID; this corresponds to the mongrel2 server the response will
	# be routed to by the Connection.
	attr_accessor :sender_id

	# The response's connection ID; this corresponds to the identifier of the connection
	# the response will be routed to by the mongrel2 server
	attr_accessor :conn_id

	# The body of the response as an IO (or IOish) object
	attr_reader :body

	# The request that this response is for, if there is one
	attr_accessor :request

	# The number of bytes to write to Mongrel in a single "chunk"
	attr_accessor :chunksize

	# The name of the extended reply filter to use in the reply. If this is set
	# the response will be send back to Mongrel as an extended reply.
	attr_reader :extended_reply_filter

	# The Array of data to include with the extended reply
	attr_reader :extended_reply_data


	### Set the response's entity body to +newbody+. If +newbody+ is a String-ish object
	### (i.e., it responds to #to_str), it will be wrapped in a StringIO in 'a+' mode).
	def body=( newbody )
		newbody = StringIO.new( newbody.dup, 'a+' ) if newbody.respond_to?( :to_str )
		@body = newbody
	end


	### Append the given +object+ to the response body. Returns the response for
	### chaining.
	def <<( object )
		self.body << object
		return self
	end


	### Write the given +objects+ to the response body, calling #to_s on each one.
	def puts( *objects )
		self.body.puts( *objects )
	end


	### Set up the response to send an extended reply to Mongrel2, invoking the
	### given +filter+. The body of the response will be passed to the filter
	### after being serialized to a tnetstring.
	def extend_reply_with( filter )
		@extended_reply_filter = filter
	end
	alias_method :extended_reply_with, :extend_reply_with


	### Returns +true+ if the response has been set to use an extended reply.
	def extended_reply?
		return @extended_reply_filter ? true : false
	end


	### Stringify the response, which just returns its body.
	def to_s
		pos = self.body.pos
		self.body.pos = 0
		return self.body.read
	ensure
		self.body.pos = pos
	end


	### Yield chunks of the response to the caller's block. By default, just yields
	### the result of calling #to_s on the response.
	def each_chunk
		if block_given?
			yield( self.to_s )
		else
			return [ self.to_s ].to_enum
		end
	end


	### Returns a string containing the request's sender and connection IDs
	### separated by a colon.
	def socket_id
		return "%s:%d" % [ self.sender_id, self.conn_id ]
	end



	### Returns a string containing a human-readable representation of the Response,
	### suitable for debugging.
	def inspect
		return "#<%p:0x%016x %s (%s)>" % [
			self.class,
			self.object_id * 2,
			self.inspect_details,
			self.socket_id
		]
	end


	#########
	protected
	#########

	### Return the details to include in the contents of the #inspected object. This
	### method allows other request types to provide their own details while keeping
	### the form somewhat consistent.
	def inspect_details
		return "%p body" % [ self.body.class ]
	end

end # class Mongrel2::Response

# vim: set nosta noet ts=4 sw=4:

