#coding: utf-8
system 'clear'

module Msg
	def self.included base
		puts "класс #{base} включил в себя модуль #{self}"
		base.extend self
	end

	def info(msg)
		if self.is_a? Module then
			color = self::COLOR
		else
			color = self.class::COLOR
		end
		
		puts "#{msg} (#{color})"
	end
end


class Foo
	COLOR = :green

	include Msg
end

Foo.new.info 'информация к размышлению'
Foo.info 'я был в Томске'
