module ApplicationHelper
  
  def include_flash_images
    if Themes::is_general?
      tag('img', src: "/images/general.png", id: 'general_img') +
      tag('img', src: "/images/bubbles.png", id: 'speech_img')
    end
  end
  
  def truncate(message, num_chars = 100)
    if message.size <= num_chars
      message
    else
      message[0...num_chars] + '...'
    end
  end
  
  def strip_tags(text)
    text.gsub tag_regex, ''
  end
  
  def restore_tags(text)
    text.gsub tag_regex, '<\1>'
  end
  
  private
    def tag_regex
      allowed_tags = %w[em i strong b code samp tt s strike sup sub a img
        blockquote pre ul ol li table tr td p]
      tag = "(#{allowed_tags.join('|')})"
      /&lt;(\/?#{tag}( .*?)?)&gt;/o
    end
end
