#coding: utf-8
system 'clear'

class Foo
	def self.make(&block)
		puts "#{self}.#{__method__}('#{block}')"

		# если я вызываю блок здесь, он выполняется в контексте класса Foo ?
		# if block_given? then
		# 	puts " блок есть: #{block} (class: #{block.class})"
		# 	puts " self: #{self} (class: #{self.class})"

		# 	puts '-------- self.make (начало) --------'
			
		# 	[Foo,Object,Class,Module,Proc,self].each do |thing|
		# 		puts " block.kind_of?(#{thing}): #{block.send('kind_of?',thing)}"
		# 		puts " block.instance_of?(#{thing}): #{block.send('instance_of?',thing)}"
		# 		puts " block==#{thing}: #{block==thing}"
		# 		puts ''
		# 	end

		# 	[Foo,Object,Class,Module,Proc,self].each do |thing|
		# 		puts " self.kind_of?(#{thing}): #{self.send('kind_of?',thing)}"
		# 		puts " self.instance_of?(#{thing}): #{self.send('instance_of?',thing)}"
		# 		puts " self==#{thing}: #{self==thing}"
		# 		puts ''
		# 	end

		# 	puts '-------- self.make (перед _eval) --------'

		# 	puts ' instance_eval...'
		# 	instance_eval(&block)
		# 	puts ''

		# 	puts ' class_eval...'
		# 	class_eval(&block)
		# 	puts ''

		# 	puts '-------- self.make (конец) --------'
		# end

		self.new(&block)
		#self.new
	end

	# если вызываю блок тут, он выполняется в контексте объекта Foo ?
	def initialize(&block)
		puts "============= #{self}.#{__method__}(блок: #{block}) =============="

		if block_given? then
			puts " блок есть: #{block} (class: #{block.class})"
			puts " self: #{self} (class: #{self.class})"

			puts '-------- #{__method__} (начало) --------'
			
			[Foo,Object,Class,Module,Proc,self].each do |thing|
				puts " block.kind_of?(#{thing}): #{block.send('kind_of?',thing)}"
				puts " block.instance_of?(#{thing}): #{block.send('instance_of?',thing)}"
				puts " block==#{thing}: #{block==thing}"
				puts ''
			end

			[Foo,Object,Class,Module,Proc,self].each do |thing|
				puts " self.kind_of?(#{thing}): #{self.send('kind_of?',thing)}"
				puts " self.instance_of?(#{thing}): #{self.send('instance_of?',thing)}"
				puts " self==#{thing}: #{self==thing}"
				puts ''
			end

			puts '-------- #{__method__} (перед _eval) --------'

			puts ' instance_eval...'
			instance_eval(&block)
			puts ''

			puts ' class_eval...'
			class_eval(&block)
			puts ''

			puts '-------- #{__method__} (конец) --------'
		end
	end
end

foo = Foo.make do
	puts '-------- в блоке --------'
	puts " в текущем контексте self = #{self} (class: #{self.class}, superclass: #{self.superclass})"

	[Foo,Object,Class,Module,Proc,self].each do |thing|
		puts " self.kind_of?(#{thing}): #{self.send('kind_of?',thing)}"
		puts " self.instance_of?(#{thing}): #{self.send('instance_of?',thing)}"
		puts " self==#{thing}: #{self==thing}"
		puts ''
	end
	puts '-------- в блоке --------'
end
