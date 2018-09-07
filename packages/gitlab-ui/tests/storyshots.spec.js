import initStoryshots from '@storybook/addon-storyshots';
import { imageSnapshot } from '@storybook/addon-storyshots-puppeteer';
import { timeoutStoryBeforeScreenshot } from './config';

const beforeScreenshot = (page, {context : {kind, story}, url}) => {
  const shouldDelay = timeoutStoryBeforeScreenshot.includes(kind);

  const delayedResolve = new Promise(resolve =>
      setTimeout(() => {
          resolve();
      }, 600)
  )

  return shouldDelay ? delayedResolve : Promise.resolve;
}

initStoryshots({
  suite: 'Image storyshots',
  test: imageSnapshot({
    storybookUrl: `file:///${__dirname}/../storybook`,
    beforeScreenshot,
  })
});
