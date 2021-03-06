# -*- ruby -*-
# frozen_string_literal: true

require_relative '../helpers'

require 'rspec'

require 'tnetstring'

require 'mongrel2'
require 'mongrel2/request'
require 'mongrel2/response'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Response do

	it "can create a matching response given a Mongrel2::Request" do
		req = Mongrel2::Request.new( TEST_UUID, 8, '/path', {}, '' )
		response = Mongrel2::Response.from_request( req )

		expect( response ).to be_a( Mongrel2::Response )
		expect( response.sender_id ).to eq( req.sender_id )
		expect( response.conn_id ).to eq( req.conn_id )
		expect( response.request ).to equal( req )
	end


	it "can be created with a body" do
		response = Mongrel2::Response.new( TEST_UUID, 8, 'the body' )
		expect( response.body.read ).to eq( 'the body' )
	end


	it "stringifies to its body contents" do
		response = Mongrel2::Response.new( TEST_UUID, 8, 'the body' )
		expect( response.to_s ).to eq( 'the body' )
	end


	it "can be streamed in chunks" do
		response = Mongrel2::Response.new( TEST_UUID, 8, 'the body' )
		expect {|b| response.each_chunk(&b) }.to yield_with_args( 'the body' )
	end


	it "can generate an enumerator for its body stream" do
		response = Mongrel2::Response.new( TEST_UUID, 8, "the body" )
		expect( response.each_chunk ).to be_a( Enumerator )
	end


	it "wraps stringifiable bodies set via the #body= accessor in a StringIO" do
		response = Mongrel2::Response.new( TEST_UUID, 8 )
		response.body = 'a stringioed body'
		expect( response.body ).to be_a( StringIO )
		expect( response.body.string ).to eq( 'a stringioed body' )
	end


	it "doesn't try to wrap non-stringfiable bodies in a StringIO" do
		response = Mongrel2::Response.new( TEST_UUID, 8 )
		testbody = Object.new
		response.body = testbody
		expect( response.body ).to be( testbody )
	end


	it "can return an ID for which sender and connection it's for" do
		response = Mongrel2::Response.new( TEST_UUID, 8 )

		expect( response.socket_id ).to eq( "#{response.sender_id}:#{response.conn_id}" )
	end


	context	"an instance with default values" do

		let( :response ) { Mongrel2::Response.new(TEST_UUID, 8) }


		it "has an empty-IO body" do
			response.body.rewind
			expect( response.body.read ).to eq( '' )
		end


		it "supports the append operator to append objects to the body IO" do
			response << 'some body stuff' << ' and some more body stuff'
			response.body.rewind
			expect( response.body.read ).to eq( 'some body stuff and some more body stuff' )
		end


		it "supports #puts for appending objects to the body IO separated by EOL" do
			response.puts( "some body stuff\n", " and some more body stuff\n\n", :and_a_symbol )
			response.body.rewind
			expect( response.body.read ).to eq( "some body stuff\n and some more body stuff\n\nand_a_symbol\n" )
		end


		it "is not an extended reply" do
			expect( response ).to_not be_extended_reply
		end

	end


	context "an instance extended with a :sendfile reply" do

		let( :response ) do
			res = Mongrel2::Response.new( TEST_UUID, 213 )
			res.extend_reply_with( :sendfile )
			res.extended_reply_data << '/path/to/a/file.txt'
			res
		end


		it "is an extended reply" do
			expect( response ).to be_extended_reply
		end

	end

end

