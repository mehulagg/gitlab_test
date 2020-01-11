<template>
  <input ref="input" name="protected_branch_ids" type="hidden" />
</template>

<script>
import $ from 'jquery';
import 'select2/select2';
import { __ } from '~/locale';
import { mapState } from 'vuex';

const anyBranch = {
  id: null,
  name: __('Any branch'),
};

function formatSelection(object) {
  return object.name;
}

function formatResult(result) {
  const isAnyBranch = result.id ? `font-monospace` : '';

  return `
    <span class="result-name ${isAnyBranch}">${result.name}</span>
  `;
}

function matcher(term, text, opt) {
  const { name } = opt;
  return name.toUpperCase().indexOf(term.toUpperCase()) >= 0;
}

export default {
  props: {
    projectId: {
      type: String,
      required: true,
    },
    initRule: {
      type: Object,
      required: false,
      default: null,
    },
  },
  computed: {
    ...mapState(['settings']),
  },
  watch: {
    value(val) {
      if (val.length > 0) {
        this.clear();
      }
    },
  },
  mounted() {
    $(this.$refs.input)
      .select2({
        minimumInputLength: 0,
        multiple: false,
        closeOnSelect: false,
        formatResult,
        formatSelection,
        data: this.getProtectedBranches(),
        matcher,
        initSelection: (element, callback) => this.initialOption(element, callback),
        id: ({ id }) => id,
      })
      .on('change', e => this.onChange(e))
      .on('select2-open', () => {
        // https://stackoverflow.com/questions/18487056/select2-doesnt-work-when-embedded-in-a-bootstrap-modal
        // Ensure search feature works in modal
        // (known issue with our current select2 version, solved in version 4 with "dropdownParent")
        $('#project-settings-approvals-create-modal').removeAttr('tabindex', '-1');
      })
      .on('select2-close', () => {
        $('#project-settings-approvals-create-modal').attr('tabindex', '-1');
      });
  },
  beforeDestroy() {
    $(this.$refs.input).select2('destroy');
  },

  methods: {
    clear() {
      $(this.$refs.input).select2('data', []);
    },
    getProtectedBranches() {
      return [anyBranch, ...this.settings.protectedBranches];
    },
    onChange() {
      // call data instead of val to get array of objects
      const value = $(this.$refs.input).select2('data');
      this.$emit('input', value.id);
    },
    initialOption(element, callback) {
      let currentBranch = anyBranch;

      if (this.initRule && this.initRule.protectedBranches.length) {
        const { name, id } = this.initRule.protectedBranches[0] || {};
        if (id) {
          currentBranch = { name, id };
          this.selectedId = id;
        }
      }
      return callback(currentBranch);
    },
  },
};
</script>
