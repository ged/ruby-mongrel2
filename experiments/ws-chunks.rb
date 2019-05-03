# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2/websocket'

# Working out the interface for fragmented websocket data stream.


io = File.open( 'song.mp3', encoding: 'binary' )


Mongrel2::WebSocket::Frame.each_fragment( io, :binary, size: 1024 ) do |frame|
	conn.broadcast( sender_id, conn_ids, frame.to_s )
end


