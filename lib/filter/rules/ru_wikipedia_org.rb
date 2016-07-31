#coding: utf-8

require File.join(File.dirname(__FILE__),'default.rb')

class RuWikipediaOrg < DefaultSite
	SCHEME = 'http[s]?'
	HOST = 'ru\.wikipedia\.org'

	class WikipediaPage < DefaultPage
		def page(dom)
			debug_msg " #{self}.#{__method__}(#{dom.class})"
			
			dom = remove_script(dom)
				debug_msg " #{dom.class}, размер: #{dom.to_xhtml.size}"
			
			dom = remove_noscript(dom)
				debug_msg " #{dom.class}, размер: #{dom.to_xhtml.size}"
			
			return dom
		end
		
		private
		
		def remove_navigation(dom)
			debug_msg " #{self}.#{__method__}(#{dom.class})"
			
			[
				"//div[@id='mw-navigation']",
				"//table[@class='navbox']",
				"//table[contains(@class,'navigation-box')]",
				
				"//div[@id='mw-hidden-catlinks']",
				"//div[@id='mw-normal-catlinks']",	
				
				"//*[@id='footer-places']",
				"//*[@id='footer-icons']",
				
				"//span[@class='mw-editsection']",
				
				"//div[@class='mw-indicators']",
			].each { |xpath|
				dom.search(xpath).remove
			}
			
			return dom
		end 
	end

	class MainPage < WikipediaPage
		def accept
			[
				'/?', 
				'/wiki/Заглавная_страница', 
				'/wiki/%D0%97%D0%B0%D0%B3%D0%BB%D0%B0%D0%B2%D0%BD%D0%B0%D1%8F_%D1%81%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0'
			]
		end
		
		def page(dom)
			debug_msg " #{self}.#{__method__}(#{dom.class})"
			super
		end
	end

	class ArticlePage < WikipediaPage
		def accept
			['/wiki/[^/:]+']
		end
		
		def link(uri)
			if uri_parts = uri.match('^http[s]?://ru\.wikipedia\.org/wiki/(?<title>[^/:]+)$') then
				"https://ru.wikipedia.org/w/index.php?title=#{uri_parts[:title]}&printable=yes"
			else
				uri
			end
		end
	end

	class PrintableArticlePage < WikipediaPage
		def accept
			['/w/index.php\?title=FreeBSD&printable=yes']
		end
		
		def collect
			['ссылки на обсуждение']
		end
		
		def page(dom)
			debug_msg " #{self}.#{__method__}(#{dom.class}, #{dom.to_s.size} байт)"
			
			dom = super(dom)
				debug_msg " #{dom.class}, размер: #{dom.to_xhtml.size}"
			
			dom = remove_navigation(dom)
			
			return dom
		end
	end

	class DiscussionPage < WikipediaPage
		def links
			['/wiki/*:Обсуждение']
		end
		
		def collect
			['ссылки на статью']
		end
		
		def page(page)
			debug_msg " #{self}.#{__method__}(#{dom.class})"
			super
		end
	end
end
