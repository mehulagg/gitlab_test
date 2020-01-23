<script>
import { debounce } from 'underscore';
import api from '~/api';
import Popover from './popover.vue';
import {
  getLineIndex,
  getCurrentHoverElement,
  setCurrentHoverElement,
  getCharacterIndex,
} from '../utils';

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
            }

            return acc;
          }, {}),
        );
      })
      .catch(() => {});
  },
  methods: {
    addGlobalEventListeners() {
      this.debouncedMouseMove = debounce(this.hoverCode, 500);

      document.querySelector('.blob-viewer').addEventListener('mousemove', this.debouncedMouseMove);
    },
    hoverCode(e) {
      if (!this.lsifData) return;

      const el = e.target;
      const line = el.closest('.line');

      if (getCurrentHoverElement()) {
        getCurrentHoverElement().classList.remove('hll');
      }

      if (line) {
        const data = this.lsifData[`${getLineIndex(line)}:${getCharacterIndex(el)}`];

        if (data) {
          this.currentHoverPosition = this.getElementGlobalPosition(el);
          this.currentHoverData = data;

          el.classList.add('hll');

          setCurrentHoverElement(el);

          return;
        }
      }

      this.currentHoverPosition = null;
      this.currentHoverData = null;
    },
    getElementGlobalPosition(el) {
      return {
        x: el.offsetLeft,
        y: el.offsetTop,
        width: el.offsetWidth,
        height: el.offsetHeight,
      };
    },
  },
};
</script>

<template>
  <popover v-if="currentHoverData" :position="currentHoverPosition" :data="currentHoverData" />
</template>
