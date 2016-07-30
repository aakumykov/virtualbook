#coding: utf-8

require_relative '../filter/filter.rb'
require_relative '../msg/msg.rb'

class Spider
	include Msg
	COLOR = :green

	attr_accessor :depth, :pages_per_node, :threads

	@@source = []

	def self.create(&block)
		self.debug_msg "#{self}.#{__method__}(#{block})"
		self.new(&block)
	end

	def initialize(&block)
		debug_msg "#{self.class}.#{__method__}(#{block})"
		instance_eval(&block) if block_given?

		@threads ||= 1
	end

	def add_source(uri)
		debug_msg "#{self.class}.#{__method__}(#{uri})"
		@@source << uri
	end

	def before_load=(arg)
		@before_load = arg
	end

	def after_load=(arg)
		@after_load = arg
	end

	def download(uri=nil)
		debug_msg "#{self.class}.#{__method__}(#{uri})"

		src = uri || @@source
		src = [src] if not src.is_a? Array
			debug_msg " src: #{src}"

		threads = []
		@threads.times do |t|
			threads << Thread.new do
				if uri = src.pop then
					@before_load and uri = @before_load.call(uri)
						debug_msg "фильтрованный uri: #{uri}"
					
					page = load(uri)
						debug_msg "загружена страница: #{page.class}, размер: #{page.to_s.size} байт"
					
					@after_load and page = @after_load.call(uri,page)
						debug_msg "фильтрованная страница: #{page.class}, размер: #{page.to_s.size} байт"
				end
			end
		end

		threads.each &:join
	end

	private

	def load(arg)
		debug_msg "#{self.class}.#{__method__}(#{arg})"
	end
end


# Msg.info "#{'~'*15} вызов с блоком #{'~'*15}"

# Spider.create do |sp|
# 	sp.add_source('http://opennet.ru')
# 	#sp.add_source('http://ru.wikipedia.org/wiki/FreeBSD')
	
# 	sp.depth = 2
# 	sp.pages_per_node = 3

# 	sp.threads = 3
	
# 	sp.before_load = lambda { |uri| 
# 		sp.info 'предобработка'
# 		Filter.link(uri) 
# 	}

# 	sp.after_load = lambda { |uri,page| 
# 		sp.info 'постобработка'
# 		Filter.page(uri,page) 
# 	}
# end.download


# Msg.info "#{'~'*15} вызов объектом #{'~'*15}"

# sp = Spider.new
# sp.add_source 'http://linux.org.ru'
# sp.add_source 'http://lib.ru'
# sp.depth = 3
# sp.pages_per_node = 3
# sp.before_load = lambda { |uri| Filter.link(uri) }
# sp.after_load = lambda { |uri,page| Filter.page(uri,page) }
# data = sp.download


Msg.info "#{'~'*15} вызов объектом 2 #{'~'*15}"

sp2 = Spider.new
sp2.depth = 1
data = sp2.download 'http://bash.im/comics'
data = sp2.download 'http://geektimes.ru'
