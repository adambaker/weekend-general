module ApplicationHelper
  
  def include_flash_images
    if Themes::is_general?
      tag('img', src: "/images/general.png", id: 'general_img') +
      tag('img', src: "/images/bubbles.png", id: 'speech_img')
    end
  end
  
  def allowed_tags
    %w[em i strong b code samp tt s strike sup sub a img
        blockquote pre ul ol li table tr td p]
  end
  
end
