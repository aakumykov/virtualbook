#coding: utf-8
system 'clear'

require 'colorize'

module Msg
	DEFAULT_COLOR = :white

	def self.included base
		puts "класс #{base} включил в себя модуль #{self}"
		base.extend self
	end

	def const_missing(name)
		case name
		when :MSG_COLOR
			DEFAULT_COLOR
		else
			nil
		end
	end

	def debug_msg msg
		color msg
	end

	def info_msg msg
		color msg
	end

	private

		def color(msg)
			if self.is_a? Module then
				puts "статично (#{self})"
				color = self::MSG_COLOR
			else
				puts "динамично (#{self.class})"
				color = self.class::MSG_COLOR
			end
			
			puts "#{msg} (#{color})".send(color.to_sym)
		end
end


class Foo
	#MSG_COLOR = :green

	include Msg

	def create
		self.info_msg __method__
	end

	def destroy
		info_msg __method__
	end
end

Foo.new.info_msg 'информация к размышлению'
Foo.info_msg 'я был в Томске'
Foo.new.debug_msg 'я был в Томске'

Foo.new.create
Foo.new.destroy