require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ApplicationHelper do
  
  describe "truncate" do
    it "should reproduce short strings exactly." do
      ['foo', 'bar', 'I love you', 'God is gay'].each do |s|
        helper.truncate(s).should == s
      end
    end
    
    it "should shorten a long string to 100 characters + ellipsis." do
      result = helper.truncate(venue_attr[:description])
      result.size.should <= 103
      result[-3..-1].should == '...'
    end
    
    it "should shorten to the number of characters specified." do
      [12, 23, 40].each do |n|
        result = helper.truncate(venue_attr[:description], n)
        result.size.should <= n+3
        result[-3..-1].should == '...'
      end
    end 
  end
  
  describe "restore_tags" do
    it "should restore em, i, strong, b, code, samp, tt, s, strike, sup, sub,
        blockquote, pre, table, tr, td, and p" do
      %w[em i strong b code samp tt s strike sup sub blockquote pre p table
          tr td].each do |tag|
        result = helper.restore_tags("&lt;#{tag}&gt;Some Text&lt;/#{tag}&gt;")
        result.should == "<#{tag}>Some Text</#{tag}>"
      end
    end
    
    it 'should restore a and img.' do
      a = helper.restore_tags '&lt;a href="foo.bar.com"&gt;Some Text&lt;/a&gt;'
      a.should == '<a href="foo.bar.com">Some Text</a>'
      img = helper.restore_tags '&lt;img src="foo.bar.com/baz.png" /&gt;'
      img.should == '<img src="foo.bar.com/baz.png" />'
    end
    
          
    it 'should restore ul, ol, and li.' do
      text = <<-all_good_strings
        &lt;ol&gt;
          &lt;li&gt; First thing &lt;/li&gt;
          &lt;li&gt; Second thing &lt;/li&gt;
        &lt;ol&gt;
        &lt;ul&gt;
          &lt;li&gt; something &lt;/li&gt;
        &lt;/ul&gt;
      all_good_strings
      result = helper.restore_tags text
      result.should == <<-all_good_strings
        <ol>
          <li> First thing </li>
          <li> Second thing </li>
        <ol>
        <ul>
          <li> something </li>
        </ul>
      all_good_strings
    end
    
    it 'should not restore disallowed tags.' do
      %w[script object area field frame].each  do |tag|
        text = "&lt;#{tag}&gt;Some Text&lt;/#{tag}&gt;"
        result = helper.restore_tags "&lt;#{tag}&gt;Some Text&lt;/#{tag}&gt;"
        result.should == text
      end
    end
  end
  
  describe "strip_tags" do
    it "should strip all html tags" do
      %w[em i strong b code samp tt s strike sup sub].each do |tag|
        result = helper.strip_tags("&lt;#{tag}&gt;Some Text&lt;/#{tag}&gt;")
        result.should == "Some Text"
      end
    end
  end
end
