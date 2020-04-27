<script>
export default {
  name: 'VueEmoji',
  props: {
    emojiName: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      glEmojiObject: () => {
        return null;
      },
    };
  },
  computed: {
    emojiElement() {
      return this.glEmojiObject(this.emojiName);
    },
  },
  mounted() {
    import(/* webpackChunkName: 'emoji' */ '~/emoji')
      .then(({ glEmojiObject }) => {
        this.glEmojiObject = glEmojiObject;
      })
      .catch(() => {});
  },
  render(createElement) {
    if (!this.emojiElement) {
      return null;
    }

    return createElement('gl-emoji', {
      domProps: {
        innerHTML: this.emojiElement.innerHTML,
      },
      attrs: this.emojiElement.attrs,
      class: this.emojiElement.classList,
    });
  },
};
</script>
