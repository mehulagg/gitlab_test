import { storiesOf } from '@storybook/vue';
import { withDocs } from 'storybook-readme';

const withCustomPreview = withDocs({
  PreviewComponent: {
    data() {
      return {
        // Style the preview component container
        // Default container forcefully centers the preview element
        styles: {
          padding: '50px 35px',
          margin: '16px 0',
          border: '1px dashed rgb(229, 229, 229)',
        },
      };
    },
    template: `<div v-bind:style="styles"><slot></slot></div>`,
  },
  // Disable default footer's dashed bottom border
  FooterComponent: {},
});

function documentedStoriesOf(storyName, readme) {
  const story = storiesOf(storyName, module);

  if (process.env.NODE_ENV !== 'test') {
    story.addDecorator(withCustomPreview(readme));
  }

  return story;
}

export default documentedStoriesOf;
