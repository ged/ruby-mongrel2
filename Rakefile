#!/usr/bin/env ruby -S rake

$LOAD_PATH.unshift( '../rake-deveiate/lib', '../hglib/lib' )

require 'rake/deveiate'

Rake::DevEiate.setup( 'mongrel2' ) do |project|
	project.publish_to = 'deveiate:/usr/local/www/public/code'
end

