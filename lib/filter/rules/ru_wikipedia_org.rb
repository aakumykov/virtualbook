#coding: utf-8

require File.join(
	File.dirname(__FILE__),
	'default.rb'
)

class RuWikipediaOrg < DefaultSite
	SCHEME = 'http[s]?'
	HOST = 'ru\.wikipedia\.org'

	class WikipediaPage < DefaultPage
		RemoveScript_Filter(page)
		RemoveNoscript_Filter(page)
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
			"#{uri}?printable=yes"
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
			RemoveNavigation_Filter(page)
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
	def RemoveNavigation_Filter(page)
	end
end
