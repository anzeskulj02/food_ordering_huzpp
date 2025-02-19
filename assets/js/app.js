// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {};

Hooks.CameraHook = {
  mounted() {
    this.el.addEventListener("click", async (event) => {
      event.preventDefault(); // Prevent phx-click from firing immediately

      try {
        // Open camera and capture image immediately
        const stream = await navigator.mediaDevices.getUserMedia({ video: true });
        const track = stream.getVideoTracks()[0];
        const imageCapture = new ImageCapture(track);

        const blob = await imageCapture.takePhoto();
        track.stop(); // Stop the camera after taking the photo

        const reader = new FileReader();
        reader.onloadend = () => {
          const imageData = reader.result;

          // First, send image to LiveView
          this.pushEvent("upload_image", { image: imageData }, () => {
            this.el.click();
          });
        };
        reader.readAsDataURL(blob);
      } catch (err) {
        console.error("Error capturing image:", err);
      }
    });
  }
};

Hooks.PlaySound = {
  mounted() {
    this.handleEvent("play_sound", ({ sound }) => {
      if (sound) {
        let audio = new Audio(sound);
        audio.play().catch(err => console.error("Error playing sound:", err));
      }
    });
  }
};

Hooks.QuantityUpdater = {
  mounted() {
    console.log("QuantityUpdater hook mounted");

    // Listen for the "update_quantity" event
    this.handleEvent("update_quantity", ({ quantity }) => {
      console.log("Received update_quantity event:", quantity);
      const quantityInput = document.getElementById("quantity-input");
      if (quantityInput) {
        quantityInput.value = quantity;
      }
    });
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

