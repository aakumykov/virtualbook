#coding: utf-8
system 'clear'

class DefaultSite
	def self.links
		puts 'Получаю определения ссылок'
	end

	def RemoveScript_Filter
	end

	def RemoveNoscript_Filter
	end
end

class RuWikipediaOrg < DefaultSite
	SCHEME = 'https'
	HOST = 'ru.wikipedia.org'

	class WikipediaPage_Rule
		def process(page)
			RemoveScript_Filter(page)
			RemoveNoscript_Filter(page)
		end
	end

	class MainPage_Rule < WikipediaPage_Rule
		LINKS = ['/Заглавная_страница']
	end

	class Article_Rule
		LINKS = ['/wiki/*']
		def refirect(uri)
			"#{uri}?printable=yes"
		end
	end

	class PrintableArticle_Rule < WikipediaPage_Rule
		LINKS = ['/wiki/*?printable=yes']
		def process
			super
			RemoveNavigation_Filter(page)
		end
	end

	class DiscussionPage_Rule < WikipediaPage_Rule
		LINKS = ['/wiki/*:Обсуждение']
	end

	# фильтры
	def RemoveNavigation_Filter
	end
end

RuWikipediaOrg.links

w = RuWikipediaOrg.new