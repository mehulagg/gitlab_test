//
// This ensures a "startupcss-complete" event is always
// triggered regardless of whether the CSS files have finished
// loading before or after DOMContentLoaded
//
// For convenience, if StartupCSS is disabled,
// the event will still be triggered.
//
// Usage:
//
//    document.addEventListener(gl.startupcss ? 'startupcss-complete' : 'DOMContentLoaded', () => {});
//

const STARTUPCSS_EVENT_IF_DISABLED = true;

export default class StartupCSS {
  constructor() {
    if (!STARTUPCSS_EVENT_IF_DISABLED && Boolean(!window.gl.startupcssEnabled)) {
      return;
    }

    this.links = Array.from(document.querySelectorAll('link[data-startupcss="loading"]'));
    if (this.links.length) {
      document.addEventListener(
        'startupcss-stylesheet-activated',
        this.handleIndividualActivation.bind(this),
      );
    } else {
      document.addEventListener('DOMContentLoaded', this.complete);
    }
  }

  complete() {
    document.dispatchEvent(
      new CustomEvent('startupcss-complete', { detail: { links: this.links } }),
    );
  }

  handleIndividualActivation() {
    if (this.links.every(element => element.dataset.startupcss === 'loaded')) {
      this.complete();
    }
  }
}
