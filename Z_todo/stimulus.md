# Guide Stimulus.js

## Qu'est-ce que Stimulus ?

Stimulus est un framework JavaScript léger créé par l'équipe de Rails (Hotwire). Il permet d'ajouter du comportement JavaScript à votre HTML de manière simple et organisée, sans remplacer votre HTML existant.

**Philosophie** : Stimulus ne gère pas le rendu HTML (comme React/Vue), il ajoute du comportement à l'HTML déjà présent.

---

## Architecture de base

### 1. Structure d'un contrôleur Stimulus

Un contrôleur Stimulus se compose de 3 éléments principaux :

```javascript
// app/javascript/controllers/hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 1. TARGETS : Éléments du DOM que vous voulez manipuler
  static targets = ["name", "output"]
  
  // 2. VALUES : Données configurables depuis le HTML
  static values = {
    name: String,
    count: { type: Number, default: 0 }
  }
  
  // 3. ACTIONS : Méthodes appelées par les événements
  greet() {
    this.outputTarget.textContent = `Hello, ${this.nameTarget.value}!`
  }
  
  increment() {
    this.countValue++
    console.log(this.countValue)
  }
}
```

### 2. Connexion HTML ↔ JavaScript

```html
<!-- data-controller : Active le contrôleur Stimulus -->
<div data-controller="hello">
  
  <!-- data-hello-target : Déclare une cible -->
  <input type="text" data-hello-target="name">
  
  <!-- data-action : Déclenche une action -->
  <button data-action="click->hello#greet">Dire bonjour</button>
  
  <!-- data-hello-name-value : Passe une valeur -->
  <div data-hello-target="output" data-hello-name-value="World"></div>
</div>
```

---

## Syntaxe des attributs data

### `data-controller`
Active un ou plusieurs contrôleurs sur un élément.

```html
<!-- Un seul contrôleur -->
<div data-controller="dropdown">

<!-- Plusieurs contrôleurs -->
<div data-controller="dropdown clipboard">
```

### `data-action`
Déclenche une action sur un événement.

**Format** : `event->controller#method`

```html
<!-- Click sur un bouton -->
<button data-action="click->counter#increment">+</button>

<!-- Submit d'un formulaire -->
<form data-action="submit->search#filter">

<!-- Événement par défaut (click pour button, submit pour form) -->
<button data-action="counter#increment">+</button>

<!-- Plusieurs actions -->
<input data-action="keyup->search#filter focus->search#highlight">

<!-- Modificateurs d'événements -->
<form data-action="submit->form#save:prevent">  <!-- preventDefault() -->
<div data-action="click->menu#close:stop">      <!-- stopPropagation() -->
<input data-action="keydown.enter->form#submit"> <!-- Touche Enter uniquement -->
```

### `data-[controller]-target`
Déclare un élément comme cible accessible dans le contrôleur.

```html
<div data-controller="search">
  <input data-search-target="query">
  <div data-search-target="results"></div>
</div>
```

```javascript
// Dans le contrôleur
static targets = ["query", "results"]

search() {
  const query = this.queryTarget.value
  this.resultsTarget.innerHTML = "..."
}
```

### `data-[controller]-[value]-value`
Passe des valeurs configurables au contrôleur.

```html
<div data-controller="counter" 
     data-counter-count-value="10"
     data-counter-step-value="5">
</div>
```

```javascript
static values = {
  count: Number,
  step: Number
}

increment() {
  this.countValue += this.stepValue
}
```

---

## Exemples pratiques

### Exemple 1 : Toggle (Afficher/Masquer)

**HTML**
```html
<div data-controller="toggle">
  <button data-action="toggle#toggle">Afficher/Masquer</button>
  <div data-toggle-target="content" class="hidden">
    Contenu à afficher/masquer
  </div>
</div>
```

**JavaScript** (`app/javascript/controllers/toggle_controller.js`)
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  
  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```

---

### Exemple 2 : Compteur

**HTML**
```html
<div data-controller="counter" data-counter-count-value="0">
  <button data-action="counter#decrement">-</button>
  <span data-counter-target="display">0</span>
  <button data-action="counter#increment">+</button>
  <button data-action="counter#reset">Reset</button>
</div>
```

**JavaScript** (`app/javascript/controllers/counter_controller.js`)
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = { count: Number }
  
  increment() {
    this.countValue++
  }
  
  decrement() {
    this.countValue--
  }
  
  reset() {
    this.countValue = 0
  }
  
  // Callback automatique quand countValue change
  countValueChanged() {
    this.displayTarget.textContent = this.countValue
  }
}
```

---

### Exemple 3 : Cases à cocher multiples

**HTML**
```html
<div data-controller="checkbox">
  <input type="checkbox" data-action="checkbox#toggleAll" id="select-all">
  <label for="select-all">Tout sélectionner</label>
  
  <div>
    <input type="checkbox" data-checkbox-target="item" value="1">
    <input type="checkbox" data-checkbox-target="item" value="2">
    <input type="checkbox" data-checkbox-target="item" value="3">
  </div>
  
  <button data-action="checkbox#getSelected">Voir sélection</button>
  <div data-checkbox-target="output"></div>
</div>
```

**JavaScript** (`app/javascript/controllers/checkbox_controller.js`)
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "output"]
  
  toggleAll(event) {
    const checked = event.target.checked
    this.itemTargets.forEach(checkbox => {
      checkbox.checked = checked
    })
  }
  
  getSelected() {
    const selected = this.itemTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)
    
    this.outputTarget.textContent = `Sélectionnés : ${selected.join(", ")}`
  }
}
```

---

### Exemple 4 : Filtre de recherche en temps réel

**HTML**
```html
<div data-controller="search">
  <input type="text" 
         data-search-target="input" 
         data-action="input->search#filter"
         placeholder="Rechercher...">
  
  <ul data-search-target="list">
    <li data-search-target="item">Apple</li>
    <li data-search-target="item">Banana</li>
    <li data-search-target="item">Cherry</li>
    <li data-search-target="item">Date</li>
  </ul>
</div>
```

**JavaScript** (`app/javascript/controllers/search_controller.js`)
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "item"]
  
  filter() {
    const query = this.inputTarget.value.toLowerCase()
    
    this.itemTargets.forEach(item => {
      const text = item.textContent.toLowerCase()
      item.style.display = text.includes(query) ? "" : "none"
    })
  }
}
```

---

### Exemple 5 : Confirmation avant suppression

**HTML**
```html
<div data-controller="confirm">
  <%= link_to "Supprimer", 
              client_path(@client), 
              method: :delete,
              data: { 
                action: "confirm#ask",
                confirm_message_value: "Êtes-vous sûr de vouloir supprimer ce client ?"
              } %>
</div>
```

**JavaScript** (`app/javascript/controllers/confirm_controller.js`)
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { message: String }
  
  ask(event) {
    if (!confirm(this.messageValue)) {
      event.preventDefault()
    }
  }
}
```

---

### Exemple 6 : Modal Bootstrap avec Stimulus

**HTML**
```html
<div data-controller="modal">
  <button data-action="modal#open">Ouvrir Modal</button>
  
  <div class="modal fade" data-modal-target="element" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Titre</h5>
          <button type="button" data-action="modal#close" class="btn-close"></button>
        </div>
        <div class="modal-body">
          Contenu de la modal
        </div>
      </div>
    </div>
  </div>
</div>
```

**JavaScript** (`app/javascript/controllers/modal_controller.js`)
```javascript
import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = ["element"]
  
  connect() {
    this.modal = new Modal(this.elementTarget)
  }
  
  open() {
    this.modal.show()
  }
  
  close() {
    this.modal.hide()
  }
}
```

---

## Lifecycle Callbacks (Méthodes du cycle de vie)

Stimulus appelle automatiquement certaines méthodes à des moments clés :

```javascript
export default class extends Controller {
  // Appelé quand le contrôleur est connecté au DOM
  connect() {
    console.log("Contrôleur connecté")
  }
  
  // Appelé quand le contrôleur est déconnecté du DOM
  disconnect() {
    console.log("Contrôleur déconnecté")
  }
  
  // Appelé quand une target est ajoutée
  [targetName]TargetConnected(element) {
    console.log("Target ajoutée", element)
  }
  
  // Appelé quand une target est retirée
  [targetName]TargetDisconnected(element) {
    console.log("Target retirée", element)
  }
  
  // Appelé quand une value change
  [valueName]ValueChanged(value, previousValue) {
    console.log("Value changée", value, previousValue)
  }
}
```

---

## Créer un nouveau contrôleur

### Avec Rails generator

```bash
rails generate stimulus [nom_du_controleur]
```

Exemple :
```bash
rails generate stimulus checkbox
# Crée : app/javascript/controllers/checkbox_controller.js
```

### Manuellement

1. Créer le fichier dans `app/javascript/controllers/`
2. Nommer le fichier : `[nom]_controller.js`
3. Le contrôleur sera automatiquement disponible avec `data-controller="[nom]"`

---

## Bonnes pratiques

1. **Un contrôleur = Une responsabilité** : Gardez vos contrôleurs simples et focalisés
2. **Utilisez les values pour la configuration** : Évitez de hardcoder des valeurs
3. **Préférez les targets aux querySelector** : Plus maintenable
4. **Nommage** : Utilisez des noms descriptifs (`data-action="form#submit"` plutôt que `data-action="form#s"`)
5. **Réutilisabilité** : Créez des contrôleurs génériques réutilisables

---

## Ressources

- Documentation officielle : https://stimulus.hotwired.dev/
- Handbook : https://stimulus.hotwired.dev/handbook/introduction
- Exemples : https://github.com/hotwired/stimulus-rails
