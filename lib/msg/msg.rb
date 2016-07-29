#coding: utf-8

require 'colorize'

module Msg
	DEFAULT_COLOR = :white

	def self.included base
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
			color = self.is_a?(Module) ? self::MSG_COLOR : self.class::MSG_COLOR
			
			puts "#{msg}".send(color.to_sym)
		end
end
