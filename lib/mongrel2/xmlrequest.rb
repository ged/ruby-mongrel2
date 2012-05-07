#!/usr/bin/ruby

require 'nokogiri'
require 'loggability'

require 'mongrel2/request' unless defined?( Mongrel2::Request )


# The Mongrel2 XML Request class. Instances of this class represent a request for an XML route from
# a Mongrel2 server.
class Mongrel2::XMLRequest < Mongrel2::Request
	extend Loggability

	# Loggability API -- set up logging under the 'mongrel2' log host
	log_to :mongrel2

	# Mongrel2::Request API -- register this class as handling 'XML' requests
	register_request_type( self, :XML )


	### Parse the body as JSON.
	def initialize( sender_id, conn_id, path, headers, body, raw=nil )
		super
		self.log.debug "Parsing XML request body"
		@data = Nokogiri::XML( body )
	end


	######
	public
	######

	# The parsed request data (a Nokogiri::XML document)
	attr_reader :data


end # class Mongrel2::XMLRequest

# vim: set nosta noet ts=4 sw=4:

