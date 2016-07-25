#coding: utf-8
#system 'clear'

module Foo
	def self.make(&block)
		puts "#{self.class}.make(#{block} (#{block.class}))"
		Foo::Maker.new(&block)
	end

	class Maker
		def initialize(&block)
			puts "Maker.initialize(блок: #{block} (#{block.class}))"

			#instance_eval(&block) if block_given?
			yield 'это yield'
		end
	end
end

Foo.make do |arg|
	puts "Пользовательский блок в Foo.make(#{arg}) [#{self} (#{self.class})]"
end

include Foo
puts ''

Maker.new do |arg|
	puts "Пользовательский блок в Maker.new(#{arg}) [#{self} (#{self.class})]"
end
