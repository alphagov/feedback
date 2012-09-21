textFieldCounter = function(textElement, counterElement) {
  document.getElementById(textElement).oninput = function() {
    this.onkeydown = null;
    document.getElementById(counterElement).innerHTML = 1200- this.value.length
  }
  document.getElementById(textElement).onkeydown = function() {
    document.getElementById(counterElement).innerHTML = 1200- this.value.length
  }
}
