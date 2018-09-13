import initStoryshots from '@storybook/addon-storyshots';
import { imageSnapshot } from '@storybook/addon-storyshots-puppeteer';
import { timeoutStoryBeforeScreenshot } from './config';

const beforeScreenshot = (page) =>
  page.addStyleTag({
    path: 'tests/storyshots.css',
  });

initStoryshots({
  suite: 'Image storyshots',
  test: imageSnapshot({
    storybookUrl: `file:///${__dirname}/../storybook`,
    beforeScreenshot,
  })
});
