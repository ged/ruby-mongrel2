# -*- ruby -*-
# frozen_string_literal: true

require_relative '../helpers'

require 'mongrel2'
require 'mongrel2/connection'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Constants do

	it "defines a default configuration URI" do
		expect( Mongrel2::Constants.constants.map( &:to_sym ) ).to include( :DEFAULT_CONFIG_URI )
	end

end

