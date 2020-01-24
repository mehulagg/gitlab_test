<script>
import api from '~/api';
import Popover from './popover.vue';
import { getCurrentHoverElement, setCurrentHoverElement, addInteractionClass } from '../utils';

export default {
  components: {
    Popover,
  },
  props: {
    projectPath: {
      type: String,
      required: true,
    },
    commitId: {
      type: String,
      required: true,
    },
    path: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      lsifData: null,
      currentHoverPosition: null,
      currentHoverData: null,
    };
  },
  mounted() {
    this.addGlobalEventListeners();

    api
      .lsifData(this.projectPath, this.commitId, this.path)
      .then(({ data }) => {
        this.lsifData = Object.freeze(
          data.reduce((acc, d) => {
            if (d.hover) {
              acc[`${d.start_line}:${d.start_char}`] = d;
              addInteractionClass(d);
            }

            return acc;
          }, {}),
        );
      })
      .catch(() => {});
  },
  beforeDestroy() {
    this.removeGlobalEventListeners();
  },
  methods: {
    addGlobalEventListeners() {
      document.querySelector('.blob-viewer').addEventListener('click', this.showPopover);
    },
    removeGlobalEventListeners() {
      document.querySelector('.blob-viewer').removeEventListener('click', this.showPopover);
    },
    showPopover({ target: el }) {
      if (!this.lsifData) return;

      const isCurrentElementPopoverOpen = el.classList.contains('hll');

      if (getCurrentHoverElement()) {
        getCurrentHoverElement().classList.remove('hll');
      }

      if (el.classList.contains('js-code-navigation') && !isCurrentElementPopoverOpen) {
        const { lineIndex, charIndex } = el.dataset;

        this.currentHoverPosition = this.getElementGlobalPosition(el);
        this.currentHoverData = this.lsifData[`${lineIndex}:${charIndex}`];

        el.classList.add('hll');

        setCurrentHoverElement(el);
      } else {
        this.currentHoverPosition = null;
        this.currentHoverData = null;
      }
    },
    getElementGlobalPosition(el) {
      return {
        x: el.offsetLeft,
        y: el.offsetTop,
        height: el.offsetHeight,
      };
    },
  },
};
</script>

<template>
  <popover v-if="currentHoverData" :position="currentHoverPosition" :data="currentHoverData" />
</template>
