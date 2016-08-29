#!/usr/bin/env ruby
#coding: utf-8
system 'clear'

require_relative 'lib/msg/msg.rb'
require_relative 'lib/spider/spider.rb'

DEBUG_LEVEL=1

class VirtualBook
	include Msg

	attr_accessor :title, :author, :language

	# системные методы
	def self.create(&block)
		debug_msg "#{self}.#{__method__}()"
		self.new(&block)
	end

	def initialize(&block)
		debug_msg "#{self}.#{__method__}()"
		instance_eval(&block) if block_given?
	end

	# вспомогательные методы
	def depth(level)
		debug_msg "#{self}.#{__method__}(#{level})"
		return self
	end

	def count(num)
		debug_msg "#{self}.#{__method__}(#{num})"
		return self
	end

	# основные методы
	def add_page(&block)
		info_msg "#{self}.#{__method__}(#{block})"
		
		pages = instance_eval(&block)
			debug_msg "#{self}.#{__method__}(): получены страницы #{pages.class}[#{pages.size}]"
		
		return self
	end

	def import(subject)
		info_msg "#{self}.#{__method__}(#{subject})"
		return self
	end

	def create_epub(opt={})
		info_msg "#{self}.#{__method__}(#{opt})"
		return self
	end

	def save(file_name)
		info_msg "#{self}.#{__method__}(#{file_name})"
	end

	private

		def method_missing name, *arg
			debug_msg "ОТСУТСТВУЕТ МЕТОД '#{name}(#{arg})'"
		end
end


Msg.info '~~~~~~~~~~~~ блоком ~~~~~~~~~~~~'

VirtualBook.create do |book|
	book.title = 'Книга'
	book.author = 'Андрей Кумыч'
	
	book.add_page do
		Spider.load ['http://opennet.ru', 'http://ru.wikipedia.org/wiki/FreeDOS']
	end

	# book.add_page do |page|
	# 	page.parent = 0
	# 	page.title = 'Глава 1'
	# 	page.content = 'glava1.html'
	# end

	#book.import('http://ru.wikipedia.org/wiki/FreeDOS')
	
	# book.import('http://opennet.ru').depth(1).count(10)
	# book.import('http://linux.org.ru')
end.create_epub.save('opennet')


#~ Msg.info ''
#~ Msg.info '~~~~~~~~~~~~ переменными ~~~~~~~~~~~~'
#~ 
#~ vb = VirtualBook.new
#~ vb.title = 'Вторая книга'
#~ vb.author = 'Андрей Кумыч'
#~ vb.import('https://ru.wikipedia.org/wiki/QNX').depth(5).count(1)
#~ book = vb.create_epub
#~ book.save('qnx')
