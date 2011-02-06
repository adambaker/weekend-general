require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ApplicationHelper. For example:
#
# describe ApplicationHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ApplicationHelper do
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
    
    it "should not mark blank search terms." do
      d = search_display(sanitized_description, ['', ' ', '   '])
      d.should_not have_selector :span, class: 'search_term'
    end
    
    it "should return nil for a nil description." do
      d = search_display(nil, ['hello'])
      d.should be_blank
    end
    
    it "should be html_safe" do
      d = search_display(sanitized_description, ['happy'])
      d.should be_html_safe
    end
  end
end
