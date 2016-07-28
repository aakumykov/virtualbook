#coding: utf-8

class DefaultSite
	SCHEME = '[^:]+'
	HOST = '[-a-z.]+'

	def find_rule(uri)
		puts "#{self.class}.#{__method__}(#{uri})"
		
		rule = @rule_index.keep_if { |pattern,rule_name|
			#puts "#{pattern}, #{uri}"
			uri.to_s.match pattern
		}
		
		return rule.first.last
	end

	def scheme
		self.class::SCHEME
	end

	def host
		self.class::HOST
	end


	def initialize
		puts "создаётся объект #{self.class}"
		index_rules
	end

	def process(*arg)
		puts "#{self.class}.#{__method__}(#{arg})"

		case arg.size
		when 1
			process_link(arg.first)
		when 2
			process_page(arg.first,arg.last)
		else
			# не опасно ли выводить здесь arg?
			raise ArgumentError "ожидается 'uri, page', получено '#{arg}'"
		end
	end

	class DefaultPage
		def accept; ['.*']; end
		def collect; []; end
		def link(uri); uri; end
		def page(page); page; end
		
		def remove_script_filter(dom)
			remove_tag(dom, 'script')
		end

		def remove_noscript_filter(dom)
			remove_tag(dom, 'noscript')
		end
		
		private
		
		def remove_tag(dom, tag_name)
			dom.search("//#{tag_name}").each { |s|
				s.remove
			}
			return dom
		end
	end

	private

	def process_link(uri)
		puts "#{self.class}.#{__method__}(#{uri})"
	end

	def process_page(uri,page)
		puts "#{self.class}.#{__method__}(#{uri},#{page.class})"
	end

	def index_rules
		#puts " внутренний метод #{self.class}.#{__method__}"

		index = {}
		self.class.constants.each do |name|
			some_class = Object.const_get("#{self.class}::#{name}")
			if some_class.is_a? Class then
				some_class.new.accept.each do |urlpath|
					index[build_pattern(self.scheme, self.host, urlpath)] = some_class
				end
			end
		end

		@rule_index = index.sort_by { |pattern,_| pattern.to_s.length }.reverse.to_h

		#puts '-'*40; @rule_index.each_pair{|k,v| puts "#{k} => #{v}"}; puts '-'*40
		
		#@rule_index
	end

	def build_pattern(scheme_regexp, host_regexp, urlpath_regexp)
		pattern = "^#{scheme_regexp}://#{(host_regexp + urlpath_regexp).gsub(/\/+/,'/')}$"
		pattern.gsub!(/^\^+/,'^')
		pattern.gsub!(/\$+$/,'$')
		Regexp.new pattern
	end
end


