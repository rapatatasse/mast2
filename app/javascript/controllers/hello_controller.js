import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "name","result" ]

  greet() {
    const element = this.nameTarget
    const name = element.value
    console.log(`Hello, ${name}!`)
    this.resultTarget.innerHTML = `
    <p>Vous utilisez Stimulus pour marquer : ${name}!</p>
    <p>ça sert a rien mais c'est une bonne base :)</p>
    <p>Retrouvez moi dans hello_controlleur</p>
`  
}
}
