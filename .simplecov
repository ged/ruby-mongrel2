# -*- ruby -*-
#encoding: utf-8

$stderr.puts "\n\n>>> Enabling coverage report.\n\n"

SimpleCov.start do
	add_filter 'spec'
	add_group "Config Classes" do |file|
		file.filename =~ %r{lib/mongrel2/config(\.rb|/.*)$}
	end
	add_group "Needing tests" do |file|
		file.covered_percent < 90
	end
end
