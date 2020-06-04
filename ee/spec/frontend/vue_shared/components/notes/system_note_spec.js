import { mount } from '@vue/test-utils';
import axios from '~/lib/utils/axios_utils';
import MockAdapter from 'axios-mock-adapter';
import IssueSystemNote from '~/vue_shared/components/notes/system_note.vue';
import createStore from '~/notes/stores';
import * as types from '~/notes/stores/mutation_types';
import waitForPromises from 'helpers/wait_for_promises';

describe('system note component', () => {
  let wrapper;
  let mock;

  const mockDiscussionData = [
    {
     id: "1234",
     notes: [ {
       discussion_id: "1234",
       id: '1424',
       author: {
         id: 1,
         name: 'Root',
         username: 'root',
         state: 'active',
         avatar_url: 'path',
         path: '/root',
       },
       note_html: '<p dir="auto">closed</p>',
       system_note_icon_name: 'status_closed',
       created_at: '2017-08-02T10:51:58.559Z',
       description_version_id: 1,
       description_diff_path: 'path/to/diff',
       delete_description_version_path: 'path/to/diff/1',
       can_delete_description_version: true,
       description_version_deleted: false,
     }]
    } 
   ]

  const diffData = '<span class="idiff">Description</span><span class="idiff addition">Diff</span>';

  function mockFetchDiff() {
    mock.onGet('/path/to/diff').replyOnce(200, diffData);
  }

  function mockDeleteDiff() {
    mock.onDelete('/path/to/diff/1').replyOnce(200, Promise.resolve());
  }

  const findBlankBtn = () => wrapper.find('.note-headline-light .btn-blank');

  const findDescriptionVersion = () => wrapper.find('.description-version');

  beforeEach(() => {
    const store = createStore();
    store.commit(types.SET_INITIAL_DISCUSSIONS, mockDiscussionData);
    const noteId = mockDiscussionData[0].notes[0].id;
    store.dispatch('setTargetNoteHash', `note_${noteId}`);

    mock = new MockAdapter(axios);
    wrapper = mount(IssueSystemNote, {
      store,
      propsData: { note: store.state.discussions[0].notes[0] },
      provide: {
        glFeatures: { saveDescriptionVersions: true, descriptionDiffs: true },
      },
    });
  });

  afterEach(() => {
    mock.restore();
    wrapper.destroy();
  });

  it('should display button to toggle description diff, description version does not display', () => {
    const button = findBlankBtn();
    expect(button.exists()).toBe(true);
    expect(button.text()).toContain('Compare with previous version');
    expect(findDescriptionVersion().exists()).toBe(false);
  });

  it('click on button to toggle description diff displays description diff with delete icon button', done => {
    mockFetchDiff();
    expect(findDescriptionVersion().exists()).toBe(false);

    const button = findBlankBtn();
    button.trigger('click');
    return wrapper.vm
      .$nextTick()
      .then(() => waitForPromises())
      .then(() => {
        expect(findDescriptionVersion().exists()).toBe(true);
        expect(findDescriptionVersion().html()).toContain(diffData);
        expect(
          wrapper
            .find('.description-version button.delete-description-history svg.ic-remove')
            .exists(),
        ).toBe(true);
        done();
      });
  });

  it('click on delete icon button deletes description diff', done => {
    mockFetchDiff();
    mockDeleteDiff();
    const button = findBlankBtn();
    button.trigger('click');
    return wrapper.vm
      .$nextTick()
      .then(() => waitForPromises())
      .then(() => {
        const deleteButton = wrapper.find({ ref: 'deleteDescriptionVersionButton' });
        deleteButton.trigger('click');
      })
      .then(() => {
        console.log("Obj ref same?(1)", wrapper.vm.note == wrapper.vm.$store.getters.discussions[0].notes[0]);
        console.log("wrapper.vm.note", wrapper.vm.note.description_version_deleted);
        console.log("wrapper.vm.$store", wrapper.vm.$store.getters.discussions[0].notes[0].description_version_deleted);
        
        return waitForPromises()
      })
      .then(() => {
        console.log("Obj ref same?(2)", wrapper.vm.note == wrapper.vm.$store.getters.discussions[0].notes[0]);
        console.log(wrapper.vm.note.description_version_deleted);
        console.log(wrapper.vm.$store.getters.discussions[0].notes[0].description_version_deleted);
        const deleteButton = wrapper.find({ ref: 'deleteDescriptionVersionButton' });
        expect(deleteButton.exists()).toBe(false);
        done();
      });
  });
});
