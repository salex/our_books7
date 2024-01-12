import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    console.log("Hello OFX!")
    console.log(this.inputTarget.value)
    // const ofxs = new ofx(this.inputTarget.value) 

  }

}
