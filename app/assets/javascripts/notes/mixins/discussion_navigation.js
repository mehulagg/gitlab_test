import { mapActions, mapState, mapGetters } from 'vuex';
import { scrollToElement } from '~/lib/utils/common_utils';
import eventHub from '../../notes/event_hub';

export default {
  data() {
    return {
      currentDiscussionId: null,
    };
  },
  computed: {
    ...mapGetters([
      'nextUnresolvedDiscussionId',
      'previousUnresolvedDiscussionId',
      'getDiscussion',
    ]),
    ...mapState({ activeTab: state => state.page.activeTab }),
    isDiffTab() {
      return this.activeTab === 'diffs';
    },
  },
  methods: {
    ...mapActions(['expandDiscussion']),
    diffsJump(id) {
      const selector = `ul.notes[data-discussion-id="${id}"]`;

      eventHub.$once('scrollToDiscussion', () => {
        const el = document.querySelector(selector);

        if (el) {
          scrollToElement(el);

          return true;
        }

        return false;
      });

      this.expandDiscussion({ discussionId: id });
    },
    discussionJump(id) {
      const selector = `div.discussion[data-discussion-id="${id}"]`;

      const el = document.querySelector(selector);

      this.expandDiscussion({ discussionId: id });

      if (el) {
        scrollToElement(el);

        return true;
      }

      return false;
    },

    switchToDiscussionsTabAndJumpTo(id) {
      window.mrTabs.eventHub.$once('MergeRequestTabChange', () => {
        setTimeout(() => this.discussionJump(id), 0);
      });

      window.mrTabs.tabShown('show');
    },

    jumpToDiscussion(discussion) {
      const { head_sha: diffSha } = discussion?.position || { head_sha: '' };
      const { short_commit_sha: discussionSha } = this.$store.state.diffs.mergeRequestDiff || {};
      const discussionOnCurrentDiff = diffSha.includes(discussionSha);
      const { id, diff_discussion: isDiffDiscussion } = discussion;
      if (id) {
        const activeTab = window.mrTabs.currentAction;

        if (activeTab === 'diffs' && isDiffDiscussion && discussionOnCurrentDiff) {
          this.diffsJump(id);
        } else if (activeTab === 'show') {
          this.discussionJump(id);
        } else {
          this.switchToDiscussionsTabAndJumpTo(id);
        }
      }
    },
    jumpToNextUnresolvedDiscussion() {
      const nextId =
        this.nextUnresolvedDiscussionId(this.currentDiscussionId, this.isDiffView) ||
        this.nextUnresolvedDiscussionId(this.currentDiscussionId, !this.isDiffView);
      const nextDiscussion = this.getDiscussion(nextId);
      if (nextDiscussion) {
        this.jumpToDiscussion(nextDiscussion);
        this.currentDiscussionId = nextId;
      }
    },
    jumpToPreviousUnresolvedDiscussion() {
      const prevId =
        this.previousUnresolvedDiscussionId(this.currentDiscussionId, this.isDiffView) ||
        this.previousUnresolvedDiscussionId(this.currentDiscussionId, !this.isDiffView);
      const prevDiscussion = this.getDiscussion(prevId);
      if (prevDiscussion) {
        this.jumpToDiscussion(prevDiscussion);
        this.currentDiscussionId = prevId;
      }
    },
  },
};
