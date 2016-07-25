#coding: utf-8
system 'clear'

class Foo
	def self.make(&block)
		if block_given? then
			# создаёт метод класса
			puts "=instance_eval="
			instance_eval(&block)
			
			puts ''
			
			# создаёт метод экземпляра
			puts "=class_eval="
			class_eval(&block)
		end

		puts ''
		self.new("создание объекта '#{self}' внутри метода '#{__method__}'")
	end

	def initialize arg=''
		puts "метод #{__method__}('#{arg}')"
	end
end

foo = Foo.make do
	puts "в текущем контексте self=#{self}(#{self.class})"
	def bar(arg='')
		puts "#{self}.#{__method__}(#{arg})"
	end
	#bar('вызов bar() внутри блока')
end

puts ''
Foo.bar("вызов метода класса 'bar' вне блока")

puts ''
puts "объект foo (вне блока): #{foo}"

puts ''
foo.bar("вызов метода экземпляра 'bar' (вне блока)")

foo.instance_eval do
	def baz arg=''
		puts "#{self}.#{__method__}(#{arg})"
	end
end

Foo.class_eval do
	def baz arg=''
		puts "#{self}.#{__method__}(#{arg})"
	end
end

Foo.instance_eval do
	def baz arg=''
		puts "#{self}.#{__method__}(#{arg})"
	end
end

puts ''
foo.baz "вызов метода экземпляра 'baz' объекта #{foo}"

puts ''
Foo.baz "вызов метода класса 'baz' объекта (класса) #{Foo}"


puts ''
puts "= объект foo2 ="
foo2 = Foo.new

puts ''
puts "foo2: #{foo2}"

foo2.bar 'foo2'
foo2.baz 'foo2'
