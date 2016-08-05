#coding: utf-8
system 'clear'

require 'nokogiri'
require_relative '../lib/msg/msg.rb'

class WWWPage
	include Msg

	def initialize(page, headers={})
		#puts "#{self}.#{__method__}(page: #{page.class}, opt: #{opt}, block: #{block})"
		
		@orig_page = page.to_s
		@headers = headers
		@recoded_page = recode_page(@orig_page, @headers)

			#File.write('recoded.html',@recoded_page)

		@page_dom = Nokogiri::HTML(@recoded_page) { |config|
			config.nonet
			config.noerror
			config.noent
		}
	end

	def text
		@page_dom.to_html
	end

	private

		def recode_page(page, headers={}, target_charset='UTF-8')
			#Msg::debug("#{self.class}.#{__method__}(page: #{page.class}, headers: #{headers})")
			
			page_charset = nil
			headers_charset = nil
			
			pattern_big=Regexp.new(/<\s*meta\s+http-equiv\s*=\s*['"]\s*content-type\s*['"]\s*content\s*=\s*['"]\s*text\s*\/\s*html\s*;\s+charset\s*=\s*(?<charset>[a-z0-9-]+)\s*['"]\s*\/?\s*>/i)
			pattern_small=Regexp.new(/<\s*meta\s+charset\s*=\s*['"]?\s*(?<charset>[a-z0-9-]+)\s*['"]?\s*\/?\s*>/i)

			temp_page = page.encode('ISO-8859-1', { :replace => '_', :invalid => :replace, :undef => :replace })
			page_charset = temp_page.match(pattern_big) || temp_page.match(pattern_small)
			page_charset = page_charset[:charset] if not page_charset.nil?
			
				#Msg::debug " page_charset: #{page_charset}"
			
			headers.each_pair { |k,v|
				if 'content-type'==k.downcase.strip then
					res = v.first.downcase.strip.match(/charset\s*=\s*(?<charset>[a-z0-9-]+)/i)
					headers_charset = res[:charset].upcase if not res.nil?
				end
			}
			
				#Msg::debug " headers_charset: #{headers_charset}"
			
			if page_charset && headers_charset then
				current_charset = headers_charset
			elsif page_charset && !headers_charset then
				current_charset = page_charset
			elsif !page_charset && headers_charset then
				current_charset = headers_charset
			else
				current_charset = 'ISO-8859-1'
			end
			
			current_charset.downcase!

				#debug_msg " current_charset: #{current_charset}"

			page = page.encode(
				target_charset, 
				current_charset, 
				{ :replace => '_', :invalid => :replace, :undef => :replace }
			)
			
			page = page.gsub(
				pattern_big,
				"<meta http-equiv='content-type' content='text/html; charset=#{target_charset}'>"
			)
			
			page = page.gsub(
				pattern_small,
				"<meta charset='#{target_charset}' />"
			)

			return page
		end
end


#page = WWWPage.new( File.read('opennet.html') )
#page = WWWPage.new( File.read('opennet.html') , {'content-type'=>['text/html;charset=KOI8-r']})
#File.write('result.html', page.text)
