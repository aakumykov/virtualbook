#coding: utf-8
system 'clear'

require_relative 'msg.rb'
require 'net/http'

def load(*arg)
	Msg.debug "#{self.class}.#{__method__}(#{arg})"

	arg = arg.first
	mode = arg.keys.first
	uri = arg.values.first
	redirects_limit = arg[:redirects_limit] || 10	# опасная логика...
	
	mode = :page

	uri = URI(uri)

		# Msg.debug " uri: #{uri}"
		# Msg.debug " mode: #{mode} (#{mode.class})"
		# Msg.debug " redirects_limit: #{redirects_limit}"

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
		#Msg.debug " скачиваю заголовки"
		mode = :headers
		request = Net::HTTP::Head.new(uri.request_uri)
	else
		#Msg.debug " скачиваю полностью"
		request = Net::HTTP::Get.new(uri.request_uri)
	end

	request['User-Agent'] = 'Кемерово'
	#request['User-Agent'] = @book.user_agent
	#request['User-Agent'] = "Mozilla/5.0 (X11; Linux i686; rv:39.0) Gecko/20100101 Firefox/39.0 [TestCrawler (admin@kempc.edu.ru)]"

	response = http.request(request)
	
		#Msg::cyan response

	case response
	when Net::HTTPSuccess
		
			#Msg.debug "response keys: #{response.to_h.keys}"
	
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

res = load head: 'http://opennet.ru'
puts "res: #{res.class}, size: #{res.size}"

puts ''
res = load page: 'http://opennet.ru', redirects_limit: 3
puts "res: #{res.class}, size: #{res.size}"
