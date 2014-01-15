#!/usr/bin/env ruby

require_relative '../helpers'

require 'rspec'

require 'tnetstring'
require 'tmpdir'
require 'tempfile'

require 'mongrel2'
require 'mongrel2/xmlrequest'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::XMLRequest do

	let( :factory ) { Mongrel2::RequestFactory.new(route: '/form') }


	it "can parse an XML request message" do

		message = make_xml_request()
		req = Mongrel2::Request.parse( message )

		expect( req ).to be_a( Mongrel2::XMLRequest )
		expect( req.sender_id ).to eq( TEST_UUID )
		expect( req.conn_id ).to eq( TEST_ID )

		expect( req.headers ).to be_a( Mongrel2::Table )
		expect( req.headers['pattern'] ).to eq( TEST_XML_HEADERS['PATH'] )
	end


end

