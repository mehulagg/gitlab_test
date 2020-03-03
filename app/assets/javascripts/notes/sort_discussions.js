import Vue from 'vue';
import SortDiscussion from './components/sort_discussion.vue';

export default store => {
  const el = document.getElementById('js-vue-sort-issue-discussions');

    return new Vue({
      el,
      name: 'SortDiscussion',
      components: {
        SortDiscussion,
      },
      store,
      render(createElement) {
        return createElement('sort-discussion', {});
      },
    });
};
