#coding: utf-8
system 'clear'

class Foo
	def method_missing name
		puts "метод экземпляра #{__method__}: не найден метод '#{name}'"
	end

	def self.method_missing name
		puts "метод класса #{__method__}: не найден метод '#{name}'"
	end
end

Foo.new.qwerty
Foo.qwerty
