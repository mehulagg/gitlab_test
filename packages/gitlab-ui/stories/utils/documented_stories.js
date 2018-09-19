import { storiesOf } from '@storybook/vue';
import { withDocs } from 'storybook-readme';

function documentedStoriesOf(storyName, readme) {
  const story = storiesOf(storyName, module);

  if (process.env.NODE_ENV !== 'test') {
    story.addDecorator(withDocs(readme));
  }

  return story;
}

export default documentedStoriesOf;
