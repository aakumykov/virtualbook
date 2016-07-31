#coding: utf-8

def foo arg={}
	uri = arg[:uri] || 'хуй'
	mode = arg[:mode] || :full

	puts "uri: #{uri}, mode: #{mode}"
end

foo
