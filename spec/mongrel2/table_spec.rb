#!/usr/bin/env ruby

require_relative '../helpers'

require 'mongrel2'
require 'mongrel2/table'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Table do


	before( :all ) do
		setup_logging()
	end

	before( :each ) do
		@table = Mongrel2::Table.new
	end

	after( :all ) do
		reset_logging()
	end



	it "allows setting/fetching case-insensitively" do

		@table['Accept'] = :accept
		@table['USER-AGENT'] = :user_agent
		@table[:accept_encoding] = :accept_encoding
		@table.accept_encoding = :accept_encoding

		expect( @table['accept'] ).to eq( :accept )
		expect( @table['ACCEPT'] ).to eq( :accept )
		expect( @table['Accept'] ).to eq( :accept )
		expect( @table[:accept] ).to eq( :accept )
		expect( @table.accept ).to eq( :accept )

		expect( @table['USER-AGENT'] ).to eq( :user_agent )
		expect( @table['User-Agent'] ).to eq( :user_agent )
		expect( @table['user-agent'] ).to eq( :user_agent )
		expect( @table[:user_agent] ).to eq( :user_agent )
		expect( @table.user_agent ).to eq( :user_agent )

		expect( @table['ACCEPT-ENCODING'] ).to eq( :accept_encoding )
		expect( @table['Accept-Encoding'] ).to eq( :accept_encoding )
		expect( @table['accept-encoding'] ).to eq( :accept_encoding )
		expect( @table[:accept_encoding] ).to eq( :accept_encoding )
		expect( @table.accept_encoding ).to eq( :accept_encoding )
	end


	it "should assign a new value when appending to a non-existing key" do
		@table.append( 'indian-meal' => 'pinecones' )
		expect( @table['Indian-Meal'] ).to eq( 'pinecones' )
	end


	it "should create an array value and append when appending to an existing key" do
		@table[:indian_meal] = 'pork sausage'
		@table.append( 'Indian-MEAL' => 'pinecones' )
		expect( @table['Indian-Meal'].size ).to eq( 2 )
		expect( @table['Indian-Meal'] ).to include('pinecones')
		expect( @table['Indian-Meal'] ).to include('pork sausage')
	end


	it "it should combine pairs in the intial hash whose keys normalize to the " +
		"same thing into an array value" do

		table = Mongrel2::Table.new({ :bob => :dan, 'Bob' => :dan_too })

		expect( table[:bob].size ).to eq( 2 )
		expect( table['Bob'] ).to include( :dan )
		expect( table['bob'] ).to include( :dan_too )
		end


	it "creates RFC822-style header lines when cast to a String" do
		table = Mongrel2::Table.new({
			:accept => 'text/html',
			'x-ice-cream-flavor' => 'mango'
		})

		table.append( 'x-ice-cream-flavor' => 'banana' )

		expect( table.to_s ).to match( %r{Accept: text/html\r\n} )
		expect( table.to_s ).to match( %r{X-Ice-Cream-Flavor: mango\r\n} )
		expect( table.to_s ).to match( %r{X-Ice-Cream-Flavor: banana\r\n} )
	end


	it "merges other Tables" do
		othertable = Mongrel2::Table.new

		@table['accept'] = 'thing'
		@table['cookie'] = 'chocolate chip'

		othertable['cookie'] = 'peanut butter'

		ot = @table.merge( othertable )
		expect( ot['accept'] ).to eq( 'thing' )
		expect( ot['cookie'] ).to eq( 'peanut butter' )
	end


	it "merges hashes after normalizing keys" do
		@table['accept'] = 'thing'
		@table['cookie-flavor'] = 'chocolate chip'

		hash = { 'CookiE_FLAVOR' => 'peanut butter' }

		ot = @table.merge( hash )
		expect( ot['accept'] ).to eq( 'thing' )
		expect( ot['cookie-flavor'] ).to eq( 'peanut butter' )
	end


	it "dupes its inner hash when duped" do
		@table['foom'] = 'a string'
		@table['frong'] = %w[eenie meenie mynie moe]

		newtable = @table.dup
		newtable['idkfa'] = 'god'
		newtable[:foom] << " and another string"
		newtable[:frong][3].replace( "mississipi" )

		expect( @table ).to_not include( 'idkfa' )
		expect( @table[:foom] ).to eq( 'a string' )
		expect( @table[:frong][3] ).to eq( 'moe' )
	end


	it "provides a case-insensitive version of the #values_at" do
		@table['uuddlrlrbas']      = 'contra_rules'
		@table['idspispopd']       = 'ghosty'
		@table['porntipsguzzardo'] = 'cha-ching'

		results = @table.values_at( :idspispopd, 'PornTipsGuzzARDO' )
		expect( results ).to eq( [ 'ghosty', 'cha-ching' ] )
	end


	it "provides an implementation of #each that returns keys as HTTP table" do
		@table.append( 'thai_food' => 'normally good' )
		@table.append( :with_absinthe => 'questionable' )
		@table.append( 'A_Number_of_SOME_sort' => 2 )
		@table.append( 'thai_food' => 'seldom hot enough' )

		values = []
		@table.each_header do |header, value|
			values << [ header, value ]
		end

		expect( values.flatten.size ).to eq( 8 )
		expect( values.transpose[0] ).to include( 'Thai-Food', 'With-Absinthe', 'A-Number-Of-Some-Sort' )
		expect( values.transpose[1] ).to include( 'normally good', 'seldom hot enough', 'questionable', '2' )
	end


	it "can yield an Enumerator for its header iterator" do
		expect( @table.each_header ).to be_a( Enumerator )
	end
end


