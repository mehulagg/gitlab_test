<script>
import Pikaday from 'pikaday';
import { GlFormInput } from '@gitlab/ui';
import { parsePikadayDate, pikadayToString } from '~/lib/utils/datetime_utility';

export default {
  components: {
    GlFormInput,
  },
  props: {
    id: {
      type: String,
      required: false,
      default: undefined,
    },
    name: {
      type: String,
      required: false,
      default: undefined,
    },
    placeholder: {
      type: String,
      required: false,
      default: undefined,
    },
    minDate: {
      type: String,
      required: false,
      default: undefined,
    },
    maxDate: {
      type: String,
      required: false,
      default: undefined,
    },
    value: {
      type: String,
      required: false,
      default: undefined,
    },
  },
  mounted() {
    this.calendar = new Pikaday({
      field: this.$refs.input,
      theme: 'gitlab-theme animate-picker',
      format: 'yyyy-mm-dd',
      container: this.$el,
      minDate: this.minDate,
      maxDate: this.maxDate,
      parse: dateString => parsePikadayDate(dateString),
      toString: date => pikadayToString(date),
      onSelect: this.handleSelect,
      onClose: this.handleClose,
      firstDay: gon.first_day_of_week,
    });

    this.$el.append(this.calendar.el);
  },
  beforeDestroy() {
    this.calendar.destroy();
  },
  methods: {
    handleSelect(dateText) {
      this.$emit('newDateSelected', this.calendar.toString(dateText));
    },
    handleClose() {
      this.$emit('hidePicker');
    },
  }
}
</script>

<template>
  <gl-form-input
    :id="id"
    ref="input"
    v-model="value"
    class="datepicker form-control"
    :placeholder="placeholder"
    autocomplete="off"
    :name="name"
  />
</template>