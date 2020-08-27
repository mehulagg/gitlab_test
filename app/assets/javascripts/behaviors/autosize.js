import Autosize from 'autosize';

const setupAutosize = () => {
  const autosizeEls = document.querySelectorAll('.js-autosize');

  Autosize(autosizeEls);
  Autosize.update(autosizeEls);
};

const checkReadyForAutosize = ev => {
  // only run when application css is set
  // beware of other URLs in other envs (eg: prod)
  if (ev.detail.startupcssHref?.match(/assets\/application/)) {
    setupAutosize();
  }
};

// Check whether to listen to StartupCSS or listening to DOMContentLoaded
const startupcssLinksLoading = document.querySelectorAll('link[data-startupcss="loading"]');
if (startupcssLinksLoading.length) {
  document.addEventListener('startupcss-stylesheets-activated', checkReadyForAutosize);
} else {
  document.addEventListener('DOMContentLoaded', setupAutosize);
}
