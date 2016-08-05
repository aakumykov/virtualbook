#coding: utf-8
system 'clear'

class Foo
	def create(&block)
		data = instance_eval(&block) if block_given?
		self.new
	end

	def initialize(&block)
		instance_eval(&block) if block_given?
	end
end

res = Foo.new do
	'текст из блока'
end

puts res