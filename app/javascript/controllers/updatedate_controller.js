import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "counter", "submitButton"]
  
  connect() {
    console.log("DEBUG: UpdateDateController connected");
    this.updateCounter()
  }

  toggleCheckbox(event) {
    console.log("DEBUG: Checkbox toggled");
    this.updateCounter()
  }

  toggleAll(event) {
    const checked = event.target.checked
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = checked
    })
    this.updateCounter()
  }

  updateCounter() {
    const selectedCount = this.getSelectedIds().length
    this.counterTarget.textContent = selectedCount
    
    // Activer/désactiver le bouton selon la sélection
    if (selectedCount > 0) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove('btn-secondary')
      this.submitButtonTarget.classList.add('btn-success')
    } else {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.remove('btn-success')
      this.submitButtonTarget.classList.add('btn-secondary')
    }
  }

  getSelectedIds() {
    return this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)
  }

  submitUpdate(event) {
    event.preventDefault()
    
    const selectedIds = this.getSelectedIds()
    
    if (selectedIds.length === 0) {
      alert("Veuillez sélectionner au moins un client")
      return
    }

    if (!confirm(`Voulez-vous vraiment mettre à jour la date de fin de ${selectedIds.length} client(s) à aujourd'hui ?`)) {
      return
    }

    // Créer un formulaire et le soumettre
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = '/clients/bulk_update_date'
    
    // Ajouter le token CSRF
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const csrfInput = document.createElement('input')
    csrfInput.type = 'hidden'
    csrfInput.name = 'authenticity_token'
    csrfInput.value = csrfToken
    form.appendChild(csrfInput)

    // Ajouter les IDs sélectionnés
    selectedIds.forEach(id => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'client_ids[]'
      input.value = id
      form.appendChild(input)
    })

    // Ajouter au DOM et soumettre
    document.body.appendChild(form)
    form.submit()
  }
}
