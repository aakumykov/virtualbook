#coding: utf-8
system 'clear'

class Foo
	attr_accessor :author

	def self.make(&block)
		puts "в #{self}.#{__method__}, self это #{self}, class: #{self.class}"
		
		self.new(&block)
	end

	def initialize(&block)
		puts "в #{self.class}.#{__method__}, self это #{self}, class: #{self.class}"
		instance_eval(&block) if block_given?
	end

	def title= arg=''
		puts "#{self}.#{__method__}(#{arg})"
		@title = arg if not arg.empty?
	end

	def title arg=''
		puts "#{self}.#{__method__}(#{arg})"
		@title = "title: '#{arg}'"
	end

	def get_title
		puts "#{self}.#{__method__}"
		@title
	end
end

foo = Foo.make do |foo|
	puts "в блоке, self это #{self}, class: #{self.class}"
	
	puts "в блоке, self.is_a? Foo: #{self.is_a? Foo}"
	puts "в блоке, self.instance_of? Foo: #{self.instance_of? Foo}"

	title 'Гагарин Юра полетел на орбиту --=8===>'
	foo.author='Автор'
end

puts foo.get_title

puts foo.author