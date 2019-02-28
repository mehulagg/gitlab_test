import { withKnobs, text } from '@storybook/addon-knobs';
import documentedStoriesOf from '../utils/documented_stories';
import readme from '../../components/regions/empty_state/empty_state.md';
import { GlEmptyState } from '../../index';

const components = {
  GlEmptyState,
};

const template = `
  <gl-empty-state
    :title="title"
    :svgPath="svgPath"
    :description="description"
    :primaryButtonText="primaryButtonText"
    :secondaryButtonText="secondaryButtonText"
    primaryButtonLink="#"
    secondaryButtonLink="#"
  />
`;

function generateProps() {
  return {
    title: {
      type: String,
      default: text('title', 'This state is empty'),
    },
    svgPath: {
      type: String,
      default:
        'https://gitlab.com/gitlab-org/gitlab-svgs/raw/master/illustrations/security-dashboard-empty-state.svg',
    },
    description: {
      type: String,
      default: text(
        'description',
        'The title and message should be clear, concise, and explain why the user is seeing this screen.'
      ),
    },
    primaryButtonText: {
      type: String,
      default: text('primary button', 'Something actionable'),
    },
    secondaryButtonText: {
      type: String,
      default: text('secondary button', 'Something else'),
    },
  };
}

documentedStoriesOf('regions|empty-state', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    components,
    template,
  }))
  .add('single button', () => ({
    props: {
      ...generateProps(),
      secondaryButtonText: {
        type: String,
        default: null,
      },
    },
    components,
    template,
  }))
  .add('no buttons', () => ({
    props: {
      ...generateProps(),
      primaryButtonText: {
        type: String,
        default: null,
      },
    },
    components,
    template,
  }))
  .add('no illustration', () => ({
    props: {
      ...generateProps(),
      svgPath: {
        type: String,
        default: null,
      },
    },
    components,
    template,
  }));
