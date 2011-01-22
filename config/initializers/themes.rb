require 'yaml'
module Themes
  THEMES = YAML.load_file(File.join(Rails.root, "config", "themes.yaml"))
  
  def self.default_theme
    THEMES["general"]
  end
  
  def self.not_signed_in
    THEMES["generic"]
  end
end
