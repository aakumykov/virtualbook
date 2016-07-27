#coding: utf-8

require 'uri'

class Filter
	def self.link(*arg)
		puts "метод класса #{self.class}.#{__method__}(#{arg})"
		self.new.link(*arg)
	end

	def self.page(*arg)
		puts "метод класса #{self.class}.#{__method__}(#{arg})"
		self.new.page(*arg)
	end

	def initialize
		puts "создаю объект #{self.class}"
		@rules_dir = 'rules'
	end

	def link(uri)
		puts "объект #{self.class} использует метод #{__method__}"
		find_filter(uri).process(uri)
	end

	def page(uri,page)
		puts "объект #{self.class} использует метод #{__method__}"
		find_filter(uri).process(uri,page)
	end

	private

	def find_filter(uri)
		puts "ищу фильтр для '#{uri}'"

		uri = URI(uri)
		
		filter_name = uri.host.downcase.gsub('.','_')
		file_name = "#{filter_name}.rb"
			#puts " file_name : #{file_name}"
		
		begin
			require_filter file_name
			object_name = filter_name.split('_').map{|p| p.capitalize}.join
		rescue
			require_filter 'default.rb'
			object_name = 'DefaultSite'
		end	
		
		filter = Object.const_get(object_name).new
			puts " фильтр: #{filter}"

		return filter
	end

	def require_filter(file_name)
		puts "закрытый метод #{self.class}.#{__method__}(#{file_name})"

		require File.realpath( 
			File.join( 
				File.dirname(File.realpath(__FILE__)), 
				"#{@rules_dir}",
				file_name 
			) 
		) 
	end
end

Filter.link('https://ru.wikipedia.org/wiki/Linux')
puts '-'*40
Filter.page('https://ru.wikipedia.org/wiki/Linux','the page')