import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "result"]

  greet() {
    const element = this.nameTarget
    const name = element.value
    console.log(`Hello, ${name}!`)
    this.resultTarget.innerHTML = `
    <p>Vous utilisez  pour marquer : ${name}!</p>
    <p>xxxxx :)</p>
    <p>Retrouvez moi dans hello_controlleur</p>
`
  }
}
