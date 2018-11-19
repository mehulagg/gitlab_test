import initStoryshots from '@storybook/addon-storyshots';
import { imageSnapshot } from '@storybook/addon-storyshots-puppeteer';

const beforeScreenshot = page => {
  // Fixing the Animation by inlining, previous approach with external file was flaky for the animation
  page.addStyleTag({
    content: `
      * {
        -webkit-transition: none !important;
        -moz-transition: none !important;
        -ms-transition: none !important;
        -o-transition: none !important;
        transition: none !important;
    
        -webkit-animation: none !important;
        -moz-animation: none !important;
        -ms-animation: none !important;
        -o-animation: none !important;
        animation: none !important;
      }
    `,
  });
};

const getGotoOptions = () => ({
  waitUntil: 'networkidle0',
});

initStoryshots({
  suite: 'Image storyshots',
  test: imageSnapshot({
    storybookUrl: `file:///${__dirname}/../storybook`,
    beforeScreenshot,
    getGotoOptions,
  }),
});
