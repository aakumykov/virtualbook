#coding: utf-8
system 'clear'

class DefaultSite
	def RemoveScript_Filter(page)
	end

	def RemoveNoscript_Filter(page)
	end
end

class DefaultPage
	def link(uri)
		uri
	end
	def page(page)
		page
	end
end

class RuWikipediaOrg < DefaultSite
	SCHEME = 'https'
	HOST = 'ru.wikipedia.org'

	class WikipediaPage < DefaultPage
		LINKS = []
		COLLECT = ['ссылка на статью']
		def page(page)
			RemoveScript_Filter(page)
			RemoveNoscript_Filter(page)
		end
	end

	class MainPage < WikipediaPage
		LINKS = ['/Заглавная_страница']
	end

	class Article
		LINKS = ['/wiki/*']
		def link(uri)
			"#{uri}?printable=yes"
		end
	end

	class PrintableArticle < WikipediaPage
		LINKS = ['/wiki/*?printable=yes']
		COLLECT = ['ссылки на обсуждение'] + superclass::LINKS
		def page(page)
			super
			RemoveNavigation_Filter(page)
		end
	end

	class DiscussionPage < WikipediaPage
		LINKS = ['/wiki/*:Обсуждение']
		COLLECT = ['ссылки на статью']
		def page(page)
		end
	end

	# фильтры
	def RemoveNavigation_Filter(page)
	end
end

w = RuWikipediaOrg.new
#w.links