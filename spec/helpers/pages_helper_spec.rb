require 'spec_helper'

describe PagesHelper do
  describe 'search_display' do
    it "should highlight the search terms in span.search_term elements." do
      d = search_display(sanitized_description, %w(happy terrible))
      d.should have_selector 'span', content: 'Happy', class: 'search_term'
      d.should have_selector 'span', content: 'terrible', class: 'search_term'
    end
    
    it "should not mark anything if there are no matches." do
      d = search_display(sanitized_description, ['semaphore'])
      d.should_not have_selector 'span', class: 'search_term'
    end
  end
end
