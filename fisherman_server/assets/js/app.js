// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let Hooks = {}
Hooks.ScrollAdjust = {
  mounted(){
    const container = document.querySelector('#shellfeed-content');
    const pidAxis = document.querySelector('#pid-axis');
    const timeAxis = document.querySelector('#time-axis');
    container.addEventListener("scroll", _ => {
      pidAxis.scrollTo(container.scrollLeft, pidAxis.scrollTop);
      timeAxis.scrollTo(timeAxis.scrollLeft, container.scrollTop);
    });
    pidAxis.addEventListener("scroll", _ => {
      container.scrollTo(pidAxis.scrollLeft, container.scrollTop);
    });
    timeAxis.addEventListener("scroll", _ => {
      container.scrollTo(container.scrollLeft, timeAxis.scrollTop);
    });
  },
}

Hooks.RelativeScrollSync = {
  mounted(){
    const container = document.querySelector('#grid-content');
    const pidAxis = document.querySelector('#grid-pid-headers');
    container.addEventListener("scroll", _ => {
      pidAxis.scrollTo(container.scrollLeft, pidAxis.scrollTop);
    });
    pidAxis.addEventListener("scroll", _ => {
      container.scrollTo(pidAxis.scrollLeft, container.scrollTop);
    });
  },
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}});
liveSocket.connect()
window.liveSocket = liveSocket