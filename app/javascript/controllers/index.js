// Import and register all your controllers from the importmap under controllers/**/*_controller
import { application } from "./application"
import HelloController from "./hello_controller"
import UpdateDateController from "./updatedate_controller"

application.register("hello", HelloController)
application.register("updatedate", UpdateDateController)