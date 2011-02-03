module PagesHelper
  def search_display(description, terms)
    description = strip_tags description
    regex = terms.reduce(''){|acc, term| acc + term + '|'}
    regex = Regexp.new(regex[0...-1], true)
    
    description.gsub! regex, '<span class="search_term">\0</span>'
    description
  end
end
