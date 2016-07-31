#coding: utf-8

require 'net/http'
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
					if @before_load then
						uri = @before_load.call(uri)
						debug_msg "ФИЛЬТРОВАННЫЙ uri: #{uri}"
					end
					
					page = load page: uri
						debug_msg "загружена страница: #{page.class}, размер: #{page.to_s.size} байт"
					
					if @after_load then
						page = @after_load.call(uri,page)
						debug_msg "ФИЛЬТРОВАННАЯ страница: #{page.class}, размер: #{page.to_s.size} байт"
					end
				end
			end
		end

		threads.each &:join
	end

	private

		def load(*arg)
			debug_msg "#{self.class}.#{__method__}(#{arg})"

			arg = arg.first
			mode = arg.keys.first
			uri = arg.values.first
			redirects_limit = arg[:redirects_limit] || 10	# опасная логика...
			
			mode = :page

			uri = URI(uri)

				# debug_msg " uri: #{uri}"
				# debug_msg " mode: #{mode} (#{mode.class})"
				# debug_msg " redirects_limit: #{redirects_limit}"

			if 0==redirects_limit then
				Msg::warning " слишком много пененаправлений"
				return nil
			end

			http = Net::HTTP.start(
				uri.host, 
				uri.port, 
				:use_ssl => ('https'==uri.scheme)
			)

			if [:head, :header, :headers].include?(mode) then
				#debug_msg " скачиваю заголовки"
				mode = :headers
				request = Net::HTTP::Head.new(uri.request_uri)
			else
				#debug_msg " скачиваю полностью"
				request = Net::HTTP::Get.new(uri.request_uri)
			end

			request['User-Agent'] = 'Кемерово'
			#request['User-Agent'] = @book.user_agent
			#request['User-Agent'] = "Mozilla/5.0 (X11; Linux i686; rv:39.0) Gecko/20100101 Firefox/39.0 [TestCrawler (admin@kempc.edu.ru)]"

			response = http.request(request)
			
				#Msg::cyan response

			case response
			when Net::HTTPSuccess
				
					#debug_msg "response keys: #{response.to_h.keys}"
			
				result = {
					:data => response.body.to_s,
					:headers => response.to_hash,
				}
				
				if :headers==mode then
					return result[:headers]
				else
					return result[:data]
				end
			
			when Net::HTTPRedirection
			
				location = response['location']
					Msg::notice " http-перенаправление на '#{location}'"
				
				result =  send(__method__, {
					uri: location, 
					mode: mode,
					redirects_limit: (redirects_limit-1),
				})
			
			else
				@book.link_update(
					set: {status: "error_#{response.code}" }, 
					where: {id: @current_id}
				)
				raise " неприемлемый ответ сервера (#{response.code}, #{response.message}) для '#{@human_uri}' "
				return nil
			end
		end
end


Msg.info "#{'~'*15} вызов с блоком #{'~'*15}"

Spider.create do |sp|
	#sp.add_source('http://opennet.ru')
	sp.add_source('http://ru.wikipedia.org/wiki/FreeBSD')
	
	sp.depth = 2
	sp.pages_per_node = 3

	sp.threads = 3
	
	sp.before_load = lambda { |uri| 
		sp.info '==== предобработка ===='
		Filter.link(uri) 
	}

	sp.after_load = lambda { |uri,page| 
		sp.info '==== постобработка ===='
		Filter.page(uri,page) 
	}
end.download


# Msg.info "#{'~'*15} вызов объектом #{'~'*15}"

# sp = Spider.new
# sp.add_source 'http://linux.org.ru'
# sp.add_source 'http://lib.ru'
# sp.depth = 3
# sp.pages_per_node = 3
# sp.before_load = lambda { |uri| Filter.link(uri) }
# sp.after_load = lambda { |uri,page| Filter.page(uri,page) }
# data = sp.download


# Msg.info "#{'~'*15} вызов объектом 2 #{'~'*15}"

# sp2 = Spider.new
# sp2.depth = 1
# data = sp2.download 'http://bash.im/comics'
# data = sp2.download 'http://geektimes.ru'
