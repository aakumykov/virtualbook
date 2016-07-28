#coding: utf-8

class Spider
	attr_accessor :depth, :pages_per_node

	def self.create(&block)
		puts "#{self}.#{__method__}(#{block})"
		self.new(&block)
	end

	def initialize(&block)
		puts "#{self.class}.#{__method__}(#{block})"
		instance_eval(&block) if block_given?
	end

	def add_source(src)
		puts "#{self.class}.#{__method__}(#{src})"
	end

	def download(arg=nil)
		puts "#{self.class}.#{__method__}(#{arg})"
	end

	def before_load=(arg)
		@@before_load = arg
	end

	def after_load=(arg)
		@@after_load = arg
	end
end

puts "#{'~'*15} вызов с блоком #{'~'*15}"

Spider.create do |sp|
	sp.add_source('http://opennet.ru')
	sp.add_source('http://ru.wikipedia.org/wiki/FreeBSD')
	
	sp.depth = 2
	sp.pages_per_node = 3
	
	sp.before_load = 'Filter.link'
	sp.after_load = 'Filter.page'
end.download


puts "#{'~'*15} вызов объектом #{'~'*15}"

sp = Spider.new
sp.add_source 'http://linux.org.ru'
sp.add_source 'lib.ru'
sp.depth = 3
sp.pages_per_node = 3
sp.before_load = lambda { |uri| Filter.link(uri) }
sp.after_load = lambda { |uri,page| Filter.page(uri,page) }
data = sp.download


puts "#{'~'*15} вызов объектом 2 #{'~'*15}"

sp2 = Spider.new
sp2.depth = 1
data = sp2.download page:'http://bash.im/comics'
data = sp2.download hash:'http://bash.im/comics'
