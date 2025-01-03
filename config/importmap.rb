# Pin npm packages by running ./bin/importmap

puts "DEBUG: Configuring importmap"
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true

# Debugging
puts "DEBUG: Importmap configuration"
puts "Current directory: #{Dir.pwd}"


puts "DEBUG: Importmap configuration complete"
puts "DEBUG: Pinned modules:"
