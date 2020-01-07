<script>
/* global Mousetrap */
import 'mousetrap';
import discussionNavigation from '~/notes/mixins/discussion_navigation';

export default {
  mixins: [discussionNavigation],
  mounted() {
    Mousetrap.bind('n', () => this.jumpToNextUnresolvedDiscussion());
    Mousetrap.bind('p', () => this.jumpToPreviousUnresolvedDiscussion());
  },
  beforeDestroy() {
    Mousetrap.unbind('n');
    Mousetrap.unbind('p');
  },
  render() {
    return this.$slots.default;
  },
};
</script>
