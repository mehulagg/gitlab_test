import { withKnobs, object } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../utils/documented_stories';
import { GlBreadcrumb } from '../../index';

const components = {
  GlBreadcrumb,
};

const getItems = () => {
  const breadcrumbItems = [
    {
      text: 'First Item',
      href: '#',
    },
    {
      text: 'Second Item',
      href: '#',
    },
    {
      text: 'Third Item',
      active: true,
    },
  ];

  return object('items', breadcrumbItems);
};

documentedStoriesOf('base|breadcrumb', '')
  .addDecorator(withKnobs)
  .add('default', () => ({
    components,
    template: `
      <gl-breadcrumb
        :items="$options.items"
      />
    `,
    items: getItems(),
  }));
