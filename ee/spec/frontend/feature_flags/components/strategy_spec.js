import { mount } from '@vue/test-utils';
import { GlFormSelect, GlFormTextarea, GlFormInput, GlToken, GlDeprecatedButton } from '@gitlab/ui';
import {
  PERCENT_ROLLOUT_GROUP_ID,
  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
  ROLLOUT_STRATEGY_USER_ID,
  ROLLOUT_STRATEGY_GITLAB_USER_LIST,
} from 'ee/feature_flags/constants';
import Strategy from 'ee/feature_flags/components/strategy.vue';
import NewEnvironmentsDropdown from 'ee/feature_flags/components/new_environments_dropdown.vue';
import GitlabUserList from 'ee/feature_flags/components/strategies/gitlab_user_list.vue';

import { userList } from '../mock_data';

describe('Feature flags strategy', () => {
  let wrapper;

  const findStrategy = () => wrapper.find('[data-testid="strategy"]');

  const factory = (
    opts = {
      propsData: {
        strategy: {},
        index: 0,
        endpoint: '',
        userLists: [userList],
      },
    },
    m = mount,
  ) => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
    wrapper = m(Strategy, opts);
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  describe.each`
    name                                | parameter       | value    | newValue   | input
    ${ROLLOUT_STRATEGY_ALL_USERS}       | ${null}         | ${null}  | ${null}    | ${null}
    ${ROLLOUT_STRATEGY_PERCENT_ROLLOUT} | ${'percentage'} | ${'50'}  | ${'20'}    | ${'input'}
    ${ROLLOUT_STRATEGY_USER_ID}         | ${'userIds'}    | ${'1,2'} | ${'1,2,3'} | ${'textarea'}
  `('with strategy $name', ({ name, parameter, value, newValue, input }) => {
    let propsData;
    let strategy;

    beforeEach(() => {
      const parameters = {};
      if (parameter !== null) {
        parameters[parameter] = value;
      }
      strategy = { name, parameters, scopes: [] };
      propsData = { strategy, index: 0, endpoint: '' };
      factory({ propsData });
      return wrapper.vm.$nextTick();
    });

    it('should set the select to match the strategy name', () => {
      expect(wrapper.find(GlFormSelect).element.value).toBe(name);
    });

    it('should not show inputs for other parameters', () => {
      ['input', 'textarea', 'select']
        .filter(component => component !== input)
        .map(component => findStrategy().findAll(component))
        .forEach(inputWrapper => expect(inputWrapper).toHaveLength(0));
    });

    if (parameter !== null) {
      it(`should show the input for ${parameter} with the correct value`, () => {
        const inputWrapper = findStrategy().find(input);
        expect(inputWrapper.exists()).toBe(true);
        expect(inputWrapper.element.value).toBe(value);
      });

      it(`should emit a change event when altering ${parameter}`, () => {
        const inputWrapper = findStrategy().find(input);
        inputWrapper.setValue(newValue);
        expect(wrapper.emitted('change')).toEqual([
          [{ name, parameters: expect.objectContaining({ [parameter]: newValue }), scopes: [] }],
        ]);
      });
    }
  });
  describe('with strategy gitlabUserList', () => {
    let propsData;
    let strategy;

    beforeEach(() => {
      strategy = {
        name: ROLLOUT_STRATEGY_GITLAB_USER_LIST,
        userListId: '2',
        parameters: {},
        scopes: [],
      };
      propsData = { strategy, index: 0, endpoint: '', userLists: [userList] };
      factory({ propsData });
    });

    it('should set the select to match the strategy name', () => {
      expect(wrapper.find(GlFormSelect).element.value).toBe(ROLLOUT_STRATEGY_GITLAB_USER_LIST);
    });

    it('should not show inputs for other parameters', () => {
      expect(findStrategy().contains(GlFormTextarea)).toBe(false);
      expect(findStrategy().contains(GlFormInput)).toBe(false);
    });

    it('should show the input for userListId with the correct value', () => {
      const inputWrapper = findStrategy().find(GlFormSelect);
      expect(inputWrapper.exists()).toBe(true);
      expect(inputWrapper.element.value).toBe('2');
    });

    it('should emit a change event when altering the userListId', () => {
      const inputWrapper = findStrategy().find(GitlabUserList);
      inputWrapper.vm.$emit('change', {
        name: ROLLOUT_STRATEGY_GITLAB_USER_LIST,
        userListId: '3',
        parameters: {},
        scopes: [],
      });
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted('change')).toEqual([
          [
            {
              name: ROLLOUT_STRATEGY_GITLAB_USER_LIST,
              userListId: '3',
              scopes: [],
              parameters: {},
            },
          ],
        ]);
      });
    });
  });

  describe('with a strategy', () => {
    describe('with scopes defined', () => {
      let strategy;

      beforeEach(() => {
        strategy = {
          name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
          parameters: { percentage: '50', groupId: PERCENT_ROLLOUT_GROUP_ID },
          scopes: [{ environmentScope: '*' }],
        };
        const propsData = { strategy, index: 0, endpoint: '' };
        factory({ propsData }, mount);
      });

      it('should change the parameters if a different strategy is chosen', () => {
        const select = wrapper.find(GlFormSelect);
        select.setValue(ROLLOUT_STRATEGY_ALL_USERS);
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted('change')).toEqual([
            [
              {
                name: ROLLOUT_STRATEGY_ALL_USERS,
                parameters: {},
                scopes: [{ environmentScope: '*' }],
              },
            ],
          ]);
        });
      });

      it('should display selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.findAll(GlToken)).toHaveLength(1);
          expect(wrapper.find(GlToken).text()).toBe('production');
        });
      });

      it('should display all selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        dropdown.vm.$emit('add', 'staging');
        return wrapper.vm.$nextTick().then(() => {
          const tokens = wrapper.findAll(GlToken);
          expect(tokens).toHaveLength(2);
          expect(tokens.at(0).text()).toBe('production');
          expect(tokens.at(1).text()).toBe('staging');
        });
      });

      it('should emit selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted('change')).toEqual([
            [
              {
                name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
                parameters: { percentage: '50', groupId: PERCENT_ROLLOUT_GROUP_ID },
                scopes: [
                  { environmentScope: '*', shouldBeDestroyed: true },
                  { environmentScope: 'production' },
                ],
              },
            ],
          ]);
        });
      });

      it('should emit a delete if the delete button is clicked', () => {
        wrapper.find(GlDeprecatedButton).vm.$emit('click');
        expect(wrapper.emitted('delete')).toEqual([[]]);
      });
    });

    describe('without scopes defined', () => {
      beforeEach(() => {
        const strategy = {
          name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
          parameters: { percentage: '50', groupId: PERCENT_ROLLOUT_GROUP_ID },
          scopes: [],
        };
        const propsData = { strategy, index: 0, endpoint: '' };
        factory({ propsData });
      });

      it('should display selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.findAll(GlToken)).toHaveLength(1);
          expect(wrapper.find(GlToken).text()).toBe('production');
        });
      });

      it('should display all selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        dropdown.vm.$emit('add', 'staging');
        return wrapper.vm.$nextTick().then(() => {
          const tokens = wrapper.findAll(GlToken);
          expect(tokens).toHaveLength(2);
          expect(tokens.at(0).text()).toBe('production');
          expect(tokens.at(1).text()).toBe('staging');
        });
      });

      it('should emit selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted('change')).toEqual([
            [
              {
                name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
                parameters: { percentage: '50', groupId: PERCENT_ROLLOUT_GROUP_ID },
                scopes: [{ environmentScope: 'production' }],
              },
            ],
          ]);
        });
      });
    });
  });
});
