import Autosize from 'autosize';

document.addEventListener(
  window.gl && gl.startupcssEnabled ? 'startupcss-complete' : 'DOMContentLoaded',
  () => {
    const autosizeEls = document.querySelectorAll('.js-autosize');

    Autosize(autosizeEls);
    Autosize.update(autosizeEls);
  },
);
