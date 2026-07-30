import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { delay: { type: Number, default: 3000 } }

    connect(){
        this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
    }

    disconnect(){
        clearTimeout(this.timeout)
    }

    dismiss(){
        this.element.classList.add("flash--fade-out")

        this.element.addEventListener(
            "transitionend",
            () => this.element.remove(),
            { once: true }
        )

        setTimeout(() => this.element.remove(), 500)
    }
}
