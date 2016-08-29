#coding: utf-8

require 'colorize'

module Msg
	COLOR = :black

	def debug_msg arg
		colorize arg if DEBUG_LEVEL == 0
	end

	def info_msg arg
		colorize arg if DEBUG_LEVEL <= 1
	end

	# служебное
	self.extend self

	def self.included base
		base.extend self
	end

	def const_missing(name)
		case name
		when :COLOR
			COLOR
		else
			nil
		end
	end

	def method_missing name, *arg
		#puts "нет метода '#{name}' (#{arg})"
		if [:info,:debug,:error,:warning,:alert].include? name.to_sym then
			new_name = "#{name}_msg".to_sym
			self.send(new_name,*arg)
		end
	end

	private

	def colorize arg
		#puts "#{__method__}(), self: #{self}, self.class: #{self.class}"

		case self.class.to_s.to_sym
		when :Module
			#puts "модуль"
			color = COLOR
		when :Class
			#puts "статика"
			color = self::COLOR
		else
			#puts "динамика"
			color = self.class::COLOR
		end

		puts arg.to_s.send(color.to_sym)
	end
end
