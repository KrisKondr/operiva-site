import { Application } from "./spline-runtime.js";

const intro = document.getElementById("operiva-intro");
const canvas = document.getElementById("operiva-spline");

if (intro && canvas) {
  let spline;

  try {
    spline = new Application(canvas);
    window.operivaSpline = spline;
    window.addEventListener("operiva:intro-finish", () => spline.stop(), { once: true });

    await spline.load("./assets/operiva-robot.splinecode");

    if (!intro.isConnected) {
      spline.stop();
    } else {
      spline.setBackgroundColor("#0a0b0e");
      spline.setZoom(window.innerWidth < 620 ? 0.76 : 0.9);
      intro.classList.remove("is-spline-loading");
      intro.classList.add("is-spline-ready");
    }
  } catch (error) {
    spline?.stop();
    intro.classList.remove("is-spline-loading");
    intro.classList.add("is-spline-error");
    console.error("OPERIVA 3D scene failed to load", error);
  }
}
