#coding: utf-8
system 'clear'

require 'colorize'

module Msg
	COLOR = :black

	def debug_msg arg
		colorize arg
	end

	def info_msg arg
		colorize arg
	end

	# служебное
	self.extend self

	def self.included base
		base.extend self
	end

	def const_missing name
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

class Foo
	include Msg

	COLOR = :green

	def work
		info_msg "Я - метод '#{__method__}' объекта #{self} из класса #{self.class}"
	end
end

# Msg.info_msg '123'
# Foo.new.info_msg '345'
# Foo.info_msg '567'
# puts Msg::COLOR
# puts Foo::COLOR
# Foo.new.work

# Foo.info "Foo.info, отзовись!"
# Foo.new.debug "Отладка (Foo.debug)"

# Msg.info "наушники костной проводимости"
# Msg.debug "кости будут проводить звукъ"