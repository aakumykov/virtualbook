#coding: utf-8

require 'uri'
require 'nokogiri'

class Filter
	def self.link(*arg)
		puts "метод класса #{self}.#{__method__}(#{arg})"
		self.new.link(*arg)
	end

	def self.page(*arg)
		puts "метод класса #{self}.#{__method__}(#{arg})"
		self.new.page(*arg)
	end

	def initialize
		puts "создаётся объект #{self.class}"
		@rules_dir = 'rules'
	end

	def link(uri)
		puts "метод объекта #{self.class}.#{__method__}"
		find_filter(uri).link(uri)
	end

	def page(uri,page)
		puts "метод объекта #{self.class}.#{__method__}(uri: #{uri}, page: #{page.class})"
		
		page = Nokogiri::XML(page) { |config|
			config.nonet
			config.noerror
			config.noent
		}
		
		find_filter(uri).page(page).to_xhtml
	end

	private

	def find_filter(uri)
		puts "ищу фильтр для '#{uri}'"

		uri = URI(uri)
		
		filter_name = uri.host.downcase.gsub('.','_')
			puts " filter_name : #{filter_name}"
		file_name = "#{filter_name}.rb"
			puts " file_name : #{file_name}"
		
		#puts '@'*50
		#require '/home/andrey/разработка/ruby/virtualbook/lib/filter/rules/ru_wikipedia_org.rb'
		#puts '@'*50
		
		begin
			puts " попытка загрузить '#{file_name}' "
			require_filter(file_name)
			object_name = filter_name.split('_').map{|p| p.capitalize}.join
		rescue => e
			puts " ------------ не удалось загрузить '#{file_name}' по причине: ------------ "
			puts e.message
			puts e.backtrace
			puts " ------------------------------------------------------------ "
			puts " попытка загрузить 'default.rb' "
			require_filter 'default.rb'
			object_name = 'DefaultSite'
		end
		
		filter = Object.const_get(object_name).new
			puts "найден фильтр: #{filter}"

		rule = filter.find_rule(uri)
			puts "найдено правило: #{rule}"

		return rule.new
	end

	def require_filter(file_name)
		puts " загружаю фильтр '#{file_name}' "

		file_path = File.realpath(
			File.join(
				File.dirname(File.realpath(__FILE__)),
				"#{@rules_dir}",
				file_name
			)
		)
		
			puts "  путь к файлу: #{file_path}"
		
		require file_path
	end
end

new_link = Filter.link('https://ru.wikipedia.org/wiki/Linux')
puts "результат: #{new_link}"
puts '~'*90
puts '~'*90
new_page = Filter.page('https://ru.wikipedia.org/wiki/Linux', 'the page')
puts "результат: #{new_page.size}"