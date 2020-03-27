import { shallowMount } from '@vue/test-utils';
import { GlButton, GlFormCheckbox, GlFormInput, GlFormInputGroup, GlDatepicker } from '@gitlab/ui';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import { TEST_HOST } from 'helpers/test_constants';
import NewDeployToken from '~/deploy_tokens/components/new_deploy_token.vue';

const createNewTokenPath = `${TEST_HOST}/create`;

describe('New Deploy Token', () => {
  const factory = (containerRegistryEnabled = true) =>
    shallowMount(NewDeployToken, {
      propsData: {
        containerRegistryEnabled,
        createNewTokenPath,
      },
    });
  describe('without a container registry', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = factory(false);
    });

    it('should not show the read registry scope', () => {
      wrapper
        .findAll(GlFormCheckbox)
        .wrappers.forEach(checkbox => expect(checkbox.text()).not.toBe('read_registry'));
    });
  });

  describe('with a container registry', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = factory();
    });

    it('should show the read registry scope', () => {
      const checkbox = wrapper.findAll(GlFormCheckbox).at(1);
      expect(checkbox.text()).toBe('read_registry');
    });

    it('should make a request to create a token on submit', () => {
      const mockAxios = new MockAdapter(axios);

      const date = new Date();
      const formInputs = wrapper.findAll(GlFormInput);
      const name = formInputs.at(0);
      const username = formInputs.at(2);
      name.vm.$emit('input', 'test name');
      username.vm.$emit('input', 'test username');

      wrapper.find(GlDatepicker).vm.$emit('input', date);

      const [readRepo, readRegistry] = wrapper.findAll(GlFormCheckbox).wrappers;
      readRepo.vm.$emit('input', true);
      readRegistry.vm.$emit('input', true);

      mockAxios
        .onPost(createNewTokenPath, {
          deploy_token: {
            name: 'test name',
            expires_at: date.toISOString(),
            username: 'test username',
            read_repository: true,
            read_registry: true,
          },
        })
        .replyOnce(200, { username: 'test token username', token: 'test token' });

      wrapper.find(GlButton).vm.$emit('click');

      return axios
        .waitForAll()
        .then(() => wrapper.vm.$nextTick())
        .then(() => {
          const [tokenUsername, tokenValue] = wrapper.findAll(GlFormInputGroup).wrappers;

          expect(tokenUsername.props('value')).toBe('test token username');
          expect(tokenValue.props('value')).toBe('test token');
        });
    });
  });
});
