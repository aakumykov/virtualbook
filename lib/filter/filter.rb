#coding: utf-8

require 'uri'
require 'nokogiri'
require_relative '../msg/msg.rb'

class Filter
	include Msg
	
	COLOR = :blue

	# системные методы
	def initialize
		debug_msg "создаётся объект #{self.class}"
		@rules_dir = 'rules'
	end

	# основные методы
	def self.link(*arg)
		self.info_msg "#{self}.#{__method__}(#{arg})"
		self.new.link(*arg)
	end

	def link(uri)
		info_msg "#{self}.#{__method__}(#{uri})"
		find_filter(uri).link(uri)
	end

	def self.page(uri,page)
		self.info_msg "#{self}.#{__method__}(#{uri}, #{page.class}, #{page.to_s.size} байт)"
		self.new.page(uri,page)
	end

	def page(uri,page)
		info_msg "#{self}.#{__method__}(#{uri}, #{page.class}, #{page.to_s.size} байт)"
		
		filter = find_filter(uri)
			debug_msg " фильтр: #{filter}"
			
		page = filter.page(page)
			debug_msg " результат filter.page: #{page.class}, #{page.to_s.size} байт"
		
		return page
	end

	private

		# основные методы
		def find_filter(uri)
			debug_msg "ищу фильтр для '#{uri}'"

			uri = URI(uri)
			
			filter_name = uri.host.downcase.gsub('.','_')
				#debug_msg " filter_name : #{filter_name}"
			file_name = "#{filter_name}.rb"
				#debug_msg " file_name: #{file_name}"
			
			#debug_msg '@'*50
			#require '/home/andrey/разработка/ruby/virtualbook/lib/filter/rules/ru_wikipedia_org.rb'
			#debug_msg '@'*50
			
			begin
				#debug_msg " попытка загрузить '#{file_name}' "
				require_filter(file_name)
				object_name = filter_name.split('_').map{|p| p.capitalize}.join
			rescue => e
				# debug_msg " ------------ не удалось загрузить '#{file_name}' по причине: ------------ "
				# debug_msg e.message
				# debug_msg e.backtrace
				# debug_msg " ------------------------------------------------------------ "
				# debug_msg " попытка загрузить 'default.rb' "
				require_filter 'default.rb'
				object_name = 'DefaultSite'
			end
			
			filter = Object.const_get(object_name).new
				debug_msg "создан фильтр: #{filter}"

			rule = filter.find_rule(uri)
				debug_msg "найдено правило: #{rule}"

			return rule.new
		end

		# вспомогательные методы
		def require_filter(file_name)
			debug_msg " загружаю файл '#{file_name}' "

			file_path = File.realpath(
				File.join(
					File.dirname(File.realpath(__FILE__)),
					"#{@rules_dir}",
					file_name
				)
			)
			
				#debug_msg "  путь к файлу: #{file_path}"
			
			require file_path
		end
end

# new_link = Filter.link('https://ru.wikipedia.org/wiki/Linux')
# puts "результат: #{new_link}"
# puts '~'*90
# puts '~'*90
# new_page = Filter.page('https://ru.wikipedia.org/wiki/Linux', 'the page')
# puts "результат: #{new_page.size}"
