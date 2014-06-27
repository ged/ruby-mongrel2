#!/usr/bin/env ruby

require 'pathname'
require 'loggability'
require 'mongrel2/config'
require 'mongrel2/handler'

# A handler that sends itself in a 'sendfile' extended response.
class SendfileQuine < Mongrel2::Handler

	### Get the fully-qualified path to the handler on startup
	def initialize( * )
		super
		@path = Pathname( __FILE__ ).expand_path
		@size = @path.size
	end


	### Handle a request
	def handle( request )
		response = request.response

		response.headers.content_type = 'text/plain'
		response.headers.content_length = @size
		response.extend_reply_with( :sendfile )
		response.extended_reply_data << @path.to_s

		response
	end

end # class RequestDumper

Loggability.level = :debug

# Point to the config database, which will cause the handler to use
# its ID to look up its own socket info.
Mongrel2::Config.configure( :configdb => 'examples.sqlite' )
SendfileQuine.run( 'sendfile-quine' )

