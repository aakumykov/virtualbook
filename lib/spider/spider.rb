#coding: utf-8

require 'net/http'
require_relative '../filter/filter.rb'
require_relative '../msg/msg.rb'
require_relative '../page/www_page.rb'

class Spider
	include Msg
	COLOR = :green

	attr_accessor :depth, :pages_per_node

	@@source = []

	def self.create(&block)
		self.debug_msg "#{self}.#{__method__}(#{block})"
		self.new(&block)
	end

	def initialize(&block)
		debug_msg "#{self}.#{__method__}(#{block})"
		instance_eval(&block) if block_given?

		@threads_count ||= 1
		
		self.before_load = lambda { |uri| Filter.link(uri) }
	end

	def threads=(arg)
		@threads_count = arg.to_i
	end

	def add_source(uri)
		debug_msg "#{self}.#{__method__}(#{uri})"
		@@source << uri
	end

	def before_load=(arg)
		@before_load = arg
	end

	def after_load=(arg)
		@after_load = arg
	end

	def self.load(src)
		debug_msg "#{self}.#{__method__}(#{src})"
		self.new.load(src)
	end

	def load(uri=nil)
		debug_msg "#{self}.#{__method__}(#{uri})"

		src = uri || @@source
		src = [src] if not src.is_a? Array
			debug_msg " src: #{src}"

		results = []

		while !(links_chunk = src.shift(@threads_count)).empty? do
			debug_msg " порция URI: #{links_chunk}"
		
			threads = []
			
			links_chunk.count.times do |t|
				threads << Thread.new do
					if uri = links_chunk.pop then
						
						if @before_load then
							uri = @before_load.call(uri)
							debug_msg " ФИЛЬТРОВАННЫЙ uri: #{uri}"
						end
						
						data = download uri
							debug_msg " загружена страница размером #{data[:page].size} байт"
							#File.write('raw-page.html',data[:page])
						
						page = recode_page(data[:page], data[:headers])
							debug_msg " страница перекодирована, получившийся размер: #{page.size} байт"
							#File.write('recoded-page.html',page)
						
						dom = html2dom(page)
							debug_msg " страница преобразована в #{dom.class}, #{dom.to_s.size} байт"
						
						if @after_load then
							dom = @after_load.call(uri,dom)
							debug_msg " ФИЛЬТРОВАННАЯ страница: #{dom.class}, размер: #{dom.to_s.size} байт"
						end
						
						output_page = dom.to_xhtml
							#File.write "result.html", output_page
						
						Thread.current[:page] = output_page
						Thread.current[:headers] = data[:headers]
					end
				end
			end

			threads.each do |thr|
				t_res = thr.join
				results << WWWPage.new(
					t_res[:page],
					t_res[:headers],
				)
			end
		end

		return results
	end

	private

		def download(uri, opt={})
			debug_msg "#{self}.#{__method__}(#{uri}, #{opt})"

			mode = opt[:mode] || :full
			redirects_limit = opt[:redirects_limit] || 10	# опасная логика...

			uri = URI(uri)

				#~ debug_msg " uri: #{uri}"
				#~ debug_msg " mode: #{mode} (#{mode.class})"
				#~ debug_msg " redirects_limit: #{redirects_limit}"

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
					:page => response.body.to_s,
					:headers => response.to_hash,
				}
				
				if :headers==mode then
					return result[:headers]
				else
					return result
				end
			
			when Net::HTTPRedirection
			
				location = response['location']
					Msg::notice " http-перенаправление на '#{location}'"
				
				result =  send(__method__, location, {
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


		def recode_page(page, headers={}, target_charset='UTF-8')
			#debug_msg("#{self.class}.#{__method__}(#{page.size} байт, #{headers.keys})")
			
			return page if headers.fetch('content-type','').first.strip.match(/utf[-]?8/i)
			
			charset_pattern_big=Regexp.new(/<\s*meta\s+http-equiv\s*=\s*['"]\s*content-type\s*['"]\s*content\s*=\s*['"]\s*text\s*\/\s*html\s*;\s+charset\s*=\s*(?<charset>[a-z0-9-]+)\s*['"]\s*\/?\s*>/i)
			charset_pattern_small=Regexp.new(/<\s*meta\s+charset\s*=\s*['"]?\s*(?<charset>[a-z0-9-]+)\s*['"]?\s*\/?\s*>/i)

			charset_tag_big = "<title><meta http-equiv='content-type' content='text/html; charset=#{target_charset}'>"
			charset_tag_small = "<meta charset='#{target_charset}' />"

			page_charset = page.match(charset_pattern_big) || page.match(charset_pattern_small)
			page_charset = page_charset[:charset] if not page_charset.nil?
			
			headers.each_pair { |k,v|
				if 'content-type'==k.downcase.strip then
					res = v.first.downcase.strip.match(/charset\s*=\s*(?<charset>[a-z0-9-]+)/i)
					headers_charset = res[:charset].upcase if not res.nil?
				end
			}
			
			page_charset ||= headers_charset if page_charset.nil?
			page_charset ||= 'ISO-8859-1'

				#debug_msg " кодировка со страницы: #{page_charset}"
				#debug_msg " кодировка из заголовков: #{headers_charset}"

			page = page.encode(
				target_charset, 
				page_charset, 
				{ :replace => '_', :invalid => :replace, :undef => :replace }
			)
			
			if page.match(charset_pattern_big) then
				page = page.gsub(
					charset_pattern_big,
					charset_tag_big
				)
			elsif page.match(charset_pattern_small) then			
				page = page.gsub(
					charset_pattern_small,
					charset_tag_small
				)
			else
				page = page.gsub(
					/<\s*title\s*>/i,
					charset_tag_big
				)
			end

			return page
		end

		def html2dom(page)
			debug_msg "#{self}.#{__method__}(#{page.class}, #{page.size} байт)"
			
			dom = Nokogiri::XML(page) { |config|
				config.nonet
				config.noerror
				config.noent
			}
		end
end

# Msg.info "#{'~'*15} вызов с блоком #{'~'*15}"

#~ data = Spider.create do |sp|
	#~ sp.add_source('http://opennet.ru')
	#~ sp.add_source('http://ru.wikipedia.org/wiki/FreeBSD')
#~ 
	#~ sp.depth = 2
	#~ sp.pages_per_node = 3
#~ 
	#~ sp.threads = 3
#~ 
	#~ sp.before_load = lambda { |uri| 
		#~ sp.info '==== предобработка ===='
		#~ Filter.link(uri) 
	#~ }
#~ 
	#~ sp.after_load = lambda { |uri,page| 
		#~ sp.info '==== постобработка ===='
		#~ sp.debug "размер страницы до: #{page.to_s.size}"
		#~ Filter.page(uri,page) 
	#~ }
#~ end
#~ data = data.load
#~ #Msg.debug "data: #{data.map{|d| d.class}}"

# Msg.info "#{'~'*15} вызов объектом #{'~'*15}"

#~ sp = Spider.new
#~ sp.add_source 'http://linux.org.ru'
#~ sp.add_source 'http://lib.ru'
#~ sp.add_source 'http://opennet.ru'
#~ sp.threads = 5
#~ sp.depth = 3
#~ sp.pages_per_node = 3
#~ #sp.before_load = lambda { |uri| Filter.link(uri) }
#~ #sp.after_load = lambda { |uri,page| Filter.page(uri,page) }
#~ data = sp.load
#~ Msg.debug "data: #{data.map{|d| d.class}}"

#Msg.info "#{'~'*15} вызов объектом 2 #{'~'*15}"

#~ sp2 = Spider.new
#~ sp2.depth = 1
#~ #sp2.before_load = lambda { |uri| Filter.link(uri) }
#~ data = sp2.load 'http://bash.im/comics'
#~ Msg.debug "data: #{data.map{|d| d.class}}"


#Msg.info "#{'~'*15} прямой вызов Spider.load #{'~'*15}"

#res = Spider.load 'http://opennet.ru'
#res = Spider.load ['http://opennet.ru', 'http://linux.org.ru']
#puts "res: #{res.class}, #{res.count}"
#Spider.load 'http://ru.wikipedia.org/wiki/FreeDOS'
#Spider.load 'http://ru.wikipedia2.org/wiki/FreeDOS'
