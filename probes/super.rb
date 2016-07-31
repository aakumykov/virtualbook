#coding: utf-8
system 'clear'

class Base
	def work arg
		arg
	end
end

class Child < Base
	def work arg
		#super "#{arg}_хвост"
		super
	end
end


puts Child.new.work '123'

