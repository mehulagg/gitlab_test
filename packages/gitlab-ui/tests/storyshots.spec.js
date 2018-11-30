import initStoryshots from '@storybook/addon-storyshots';
import { imageSnapshot } from '@storybook/addon-storyshots-puppeteer';
import registerRequireContextHook from 'babel-plugin-require-context-hook/register';
import { getResetAnimationsCSS } from './test_utils';

registerRequireContextHook();

const beforeScreenshot = page => {
  // Fixing the Animation by inlining, previous approach with external file was flaky for the animation
  page.addStyleTag({
    content: getResetAnimationsCSS(),
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
