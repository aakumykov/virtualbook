#!/usr/bin/env ruby
#coding: utf-8
system 'clear'

require_relative 'lib/msg/msg.rb'


class VirtualBook
	include Msg

	attr_accessor :title, :author, :language

	def self.create(&block)
		debug_msg "#{self}.#{__method__}()"
		self.new(&block)
	end

	def initialize(&block)
		debug_msg "#{self}.#{__method__}()"
		instance_eval(&block) if block_given?
	end

	def depth(level)
		debug_msg "#{self}.#{__method__}(#{level})"
		return self
	end

	def count(num)
		debug_msg "#{self}.#{__method__}(#{num})"
		return self
	end

	def import(subject)
		debug_msg "#{self}.#{__method__}(#{subject})"
		return self
	end

	def create_epub(opt={})
		debug_msg "#{self}.#{__method__}(#{opt})"
		return self
	end

	def save(file_name)
		debug_msg "#{self}.#{__method__}(#{file_name})"
	end

	private

		def method_missing name, *arg
			debug_msg "ОТСУТСТВУЕТ МЕТОД '#{name}(#{arg})'"
		end
end


Msg.debug '~~~~~~~~~~~~ блоком ~~~~~~~~~~~~'

VirtualBook.create do |book|
	book.title = 'Книга'
	book.author = 'Андрей Кумыч'

	book.import('http://opennet.ru').depth(1).count(10)
	book.import('http://linux.org.ru')
	book.import('http://ru.wikipedia.org')
end.create_epub.save('opennet')


Msg.debug ''
Msg.debug '~~~~~~~~~~~~ переменными ~~~~~~~~~~~~'

vb = VirtualBook.new
vb.title = 'Вторая книга'
vb.author = 'Андрей Кумыч'
vb.import('https://ru.wikipedia.org/wiki/QNX').depth(5).count(1)
book = vb.create_epub
book.save('qnx')
