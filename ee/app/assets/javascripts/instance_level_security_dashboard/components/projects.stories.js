import { storiesOf } from '@storybook/vue';

import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';

const mockAPI = new MockAdapter(axios);

const Welcome = {
  name: 'Welcome',
  template: `
    <div>
      <h1>Welcome, Man!</h1>
    </div>`,
};

storiesOf('Security Dashboard', module).add('to Storybook', () => ({
  components: { Welcome },
  template: '<welcome :showApp="action" />',
}));
