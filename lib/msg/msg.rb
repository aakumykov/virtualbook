#coding: utf-8

require 'colorize'

module Msg
	def debug_msg(*arg)
		colored_message(*arg)
	end

	def info_msg(*arg)
		colored_message(*arg)
	end

	private

	def colored_message(*arg)
		color = (self.class::MSG_COLOR || :black).to_sym
		data = arg.each { |a| puts a.to_s.send(color) }
	end
end