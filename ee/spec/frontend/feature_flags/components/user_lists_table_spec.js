import { mount } from '@vue/test-utils';
import { GlModal } from '@gitlab/ui';
import UserListsTable from 'ee/feature_flags/components/user_lists_table.vue';
import { userList } from '../mock_data';

jest.mock('timeago.js', () => ({
  format: jest.fn().mockReturnValue('2 weeks ago'),
  register: jest.fn(),
}));

describe('User Lists Table', () => {
  let wrapper;
  let userLists;

  beforeEach(() => {
    userLists = new Array(5).fill(userList).map((x, i) => ({ ...x, id: i }));
    wrapper = mount(UserListsTable, {
      propsData: { userLists },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('should display the details of a user list', () => {
    expect(wrapper.find('[data-testid="listName"]').text()).toBe('test_users');
    expect(wrapper.find('[data-testid="listIds"]').text()).toBe('user3, user4, user5');
    expect(wrapper.find('[data-testid="listTimestamp"]').text()).toBe('created 2 weeks ago');
  });

  it('should set the title for a tooltip on the created stamp', () => {
    expect(wrapper.find('[data-testid="listTimestamp"]').attributes('title')).toBe(
      'Feb 4, 2020 8:13am GMT+0000',
    );
  });

  it('should display a user list entry per user list', () => {
    const lists = wrapper.findAll('[data-testid="list"]');
    expect(lists).toHaveLength(5);
    lists.wrappers.forEach(list => {
      expect(list.contains('[data-testid="listName"]')).toBe(true);
      expect(list.contains('[data-testid="listIds"]')).toBe(true);
      expect(list.contains('[data-testid="listTimestamp"]')).toBe(true);
    });
  });

  describe('delete button', () => {
    it('should display the confirmation modal', () => {
      const modal = wrapper.find(GlModal);

      wrapper.find('button').trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(modal.text()).toContain(`Delete ${userList.name}?`);
        expect(modal.text()).toContain(`User list ${userList.name} will be removed.`);
      });
    });
  });

  describe('confirmation modal', () => {
    let modal;

    beforeEach(() => {
      modal = wrapper.find(GlModal);

      wrapper.find('button').trigger('click');

      return wrapper.vm.$nextTick();
    });

    it('should emit delete with list on confirmation', () => {
      modal.find('[data-testid="modal-confirm"]').trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted('delete')).toEqual([[userLists[0]]]);
      });
    });

    it('should not emit delete with list when not confirmed', () => {
      modal.find('button').trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted('delete')).toBeUndefined();
      });
    });
  });
});
