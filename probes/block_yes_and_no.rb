#coding: utf-8
system 'clear'

class Foo
	def bar(arg=nil, &block)
		if arg.nil? then
			print "нет аргумента"
		else
			print "есть аргумент ('#{arg}'[#{arg.class}])"
		end

		if block_given? then
			puts ", есть блок, block (#{block})"
		else
			puts ", нет блока"
		end
		
		puts '~'*30
	end
end

foo = Foo.new


foo.bar 'первый'

foo.bar do
	puts 'Это выводится в блоке'
end

foo.bar 123

foo.bar('abc') do
	puts 'Это тоже в блоке, но ещё с простым аргументом'
end

foo.bar