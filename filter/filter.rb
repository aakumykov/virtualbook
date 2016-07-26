#coding: utf-8
system 'clear'

require 'uri'

class Filter
	def self.link(uri)
		puts "#{self}.#{__method__}(#{uri})"
		self.new.link(uri)
	end

	def self.page(uri,page)
		puts "#{self}.#{__method__}(#{uri},#{page.class})"
		self.new.page(uri,page)
	end

	def initialize
		puts "#{self}.#{__method__}"
		@rules_dir = 'rules'
	end

	def link(uri)
		puts "#{self}.#{__method__}(#{uri})"
		find_filter(uri).process(uri)
	end

	def page(uri,page)
		puts "#{self}.#{__method__}(#{uri},#{page.class})"
		find_filter(uri).process(uri,page)
	end

	private

	def find_filter(uri)
		uri = URI(uri)
		filter_name = uri.host.downcase.gsub('.','_')
		filter_file = "#{filter_name}.rb"
		object_name = filter_name.split('_').map{|p| p.capitalize}.join
			#puts " filter_file : #{filter_file}"
			#puts " object_name : #{object_name}"
		require File.join( File.dirname(File.realpath(__FILE__)), "#{@rules_dir}",filter_name )
		Object.const_get(object_name).new
	end

end

Filter.link('https://ru.wikipedia.org/wiki/Linux')
#Filter.page('https://ru.wikipedia.org/wiki/Linux','the page')