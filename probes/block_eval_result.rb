#coding: utf-8
system 'clear'

def foo(&block)
	instance_eval(&block) if block_given?
end

res = foo do
	'результат из блока в foo'
end

puts res