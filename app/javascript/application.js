// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import * as Popper from "@popperjs/core"
import "bootstrap"

console.log("DEBUG: Application.js loaded");
console.log("DEBUG: Imported modules:", {
    turbo: typeof import("@hotwired/turbo-rails"),
    controllers: typeof import("./controllers"),
    popper: Popper,
    bootstrap: typeof import("bootstrap")
});
