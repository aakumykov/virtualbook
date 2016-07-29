#coding: utf-8

require 'uri'
require 'nokogiri'
require_relative '../msg/msg.rb'

class Filter
	include Msg
	MSG_COLOR = :blue

	def self.link(*arg)
		self.debug_msg "метод класса #{self}.#{__method__}(#{arg})"
		self.new.link(*arg)
	end

	def self.page(*arg)
		self.debug_msg "метод класса #{self}.#{__method__}(#{arg})"
		self.new.page(*arg)
	end

	def initialize
		debug_msg "создаётся объект #{self.class}"
		@rules_dir = 'rules'
	end

	def link(uri)
		debug_msg "метод объекта #{self.class}.#{__method__}"
		find_filter(uri).link(uri)
	end

	def page(uri,page)
		debug_msg "метод объекта #{self.class}.#{__method__}(uri: #{uri}, page: #{page.class})"
		
		page = Nokogiri::XML(page) { |config|
			config.nonet
			config.noerror
			config.noent
		}
		
		find_filter(uri).page(page).to_xhtml
	end

	private

	def find_filter(uri)
		debug_msg "ищу фильтр для '#{uri}'"

		uri = URI(uri)
		
		filter_name = uri.host.downcase.gsub('.','_')
			#debug_msg " filter_name : #{filter_name}"
		file_name = "#{filter_name}.rb"
			debug_msg " file_name : #{file_name}"
		
		#debug_msg '@'*50
		#require '/home/andrey/разработка/ruby/virtualbook/lib/filter/rules/ru_wikipedia_org.rb'
		#debug_msg '@'*50
		
		begin
			#debug_msg " попытка загрузить '#{file_name}' "
			require_filter(file_name)
			object_name = filter_name.split('_').map{|p| p.capitalize}.join
		rescue => e
			debug_msg " ------------ не удалось загрузить '#{file_name}' по причине: ------------ "
			debug_msg e.message
			debug_msg e.backtrace
			debug_msg " ------------------------------------------------------------ "
			debug_msg " попытка загрузить 'default.rb' "
			require_filter 'default.rb'
			object_name = 'DefaultSite'
		end
		
		filter = Object.const_get(object_name).new
			debug_msg "найден фильтр: #{filter}"

		rule = filter.find_rule(uri)
			debug_msg "найдено правило: #{rule}"

		return rule.new
	end

	def require_filter(file_name)
		debug_msg " загружаю фильтр '#{file_name}' "

		file_path = File.realpath(
			File.join(
				File.dirname(File.realpath(__FILE__)),
				"#{@rules_dir}",
				file_name
			)
		)
		
			debug_msg "  путь к файлу: #{file_path}"
		
		require file_path
	end
end

# new_link = Filter.link('https://ru.wikipedia.org/wiki/Linux')
# puts "результат: #{new_link}"
# puts '~'*90
# puts '~'*90
# new_page = Filter.page('https://ru.wikipedia.org/wiki/Linux', 'the page')
# puts "результат: #{new_page.size}"