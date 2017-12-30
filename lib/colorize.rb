def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end 
