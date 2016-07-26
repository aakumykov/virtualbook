#coding: utf-8
system 'clear'

class DefaultSite
	def RemoveScript_Filter(page)
	end

	def RemoveNoscript_Filter(page)
	end
end

class DefaultPage
end

class RuWikipediaOrg < DefaultSite
	SCHEME = 'https'
	HOST = 'ru.wikipedia.org'

	class WikipediaPage < DefaultPage
		def page(page)
			RemoveScript_Filter(page)
			RemoveNoscript_Filter(page)
		end
	end

	class MainPage < WikipediaPage
		def accept
			['/Заглавная_страница']
		end
	end

	class Article < DefaultPage
	class Article
		def accept
			['/wiki/*']
		end
		
		def link(uri)
			"#{uri}?printable=yes"
		end
	end

	class PrintableArticle < WikipediaPage
		def accept
			['/wiki/*?printable=yes'] + super
		end
		
		def collect
			['ссылки на обсуждение'] + super
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

w = RuWikipediaOrg.new
w.rule_for('https://ru.wikipedia.org/wiki/Linux')