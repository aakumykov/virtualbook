#coding: utf-8
system 'clear'

# require 'net/http'

# http = Net::HTTP.start('opennet.ru',80)
# puts "http: #{http} (#{http.class})"
# http.finish

# Net::HTTP.new('opennet.ru',80).start do |http|
# 	puts "http: #{http} (#{http.class})"
# end

class Foo
	def self.make(&block)
		print "block внутри #{self}.#{__method__}: "
		block_given? ? puts("#{block}") : puts("его нет")

		self.new(&block)
	end

	def initialize(&block)
		print "block внутри #{self.class}.#{__method__}: "
		block_given? ? puts("#{block}") : puts("его нет")

		if block_given? then
			instance_eval(&block)
		end
	end

	def title
		puts "#{self}.#{__method__}"
		@title ? "заголовок: '#{@title}'" : "заголовок: его нет"
	end

	def title= arg
		puts "#{self}.#{__method__}('#{arg}')"
		@title = arg.to_s
	end
end

foo = Foo.make
puts "снаружи foo, foo = #{foo}"
foo.title='снаружи даёт заголовок'
puts foo.title

puts '~~~~~~~~~~~~~~~~~~'

Foo.make do |arg|
	puts "внутри foo, arg = #{arg}"
	title='блок даёт заголовок'
	puts title
end
