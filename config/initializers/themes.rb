require 'yaml'
module Themes
  THEMES = YAML.load_file(File.join(Rails.root, "config", "themes.yaml"))
  
  @@current_theme = THEMES["general"]
  
  def self.current_theme
    @@current_theme
  end
  
  def self.current_theme=( theme_name )
    @@current_theme = THEMES[theme_name]
  end
end
