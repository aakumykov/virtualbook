#coding: utf-8

require File.join(File.dirname(__FILE__),'default.rb')

class RuWikipediaOrg < DefaultSite
	SCHEME = 'http[s]?'
	HOST = 'ru\.wikipedia\.org'

	class WikipediaPage < DefaultPage
		def page(page)
			puts " #{self.class}.#{__method__}"
			page = remove_script_filter(page)
			page = remove_noscript_filter(page)
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
	end

	class Article < WikipediaPage
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

	class PrintableArticle < WikipediaPage
		def accept
			['/w/index.php\?title=FreeBSD&printable=yes']
		end
		
		def collect
			['ссылки на обсуждение']
		end
		
		def page(page)
			super
			remove_navigation_filter(page)
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
		end
	end

	# фильтры
	def remove_navigation_filter(page)
	end
end
