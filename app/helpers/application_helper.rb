module ApplicationHelper
  
  def search_display(description, terms)
    terms = terms.reject{|t| t.blank?}
    description = truncate strip_tags(description), length: 250
    
    return nil if description.blank?
    return description if terms.empty?
    
    regex = terms.reduce(''){|acc, term| acc + term + '|'}
    regex = Regexp.new(regex[0...-1], true)
    
    description.gsub! regex, '<span class="search_term">\0</span>'
    description.html_safe
  end
  
  def include_flash_images
    if theme['name'] == 'general'
      tag('img', src: "/images/general.png", id: 'general_img') +
      tag('img', src: "/images/bubbles.png", id: 'speech_img')
    end
  end
  
  def allowed_tags
    %w[em i strong b code samp tt s strike sup sub a img
        blockquote pre ul ol li table tr td p]
  end
  
  def display_format(text)
    simple_format(sanitize(text, tags: allowed_tags), {}, sanitize: false)
      .html_safe
  end
  
  def event_date(event)
    date_string '%a, %b %d', event
  end
  
  def mail_event_date(event)
    date_string '%A, %B %d', event
  end
  
  private
    def date_string(date_format, event)
      date_format += ' %Y' unless event.date.year == Time.zone.now.year
      event.date.strftime(date_format)
    end
end
