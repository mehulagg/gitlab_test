<script>
import BTable from 'bootstrap-vue/es/components/table/table';

export default {
  components: {
    BTable,
  },
  inheritAttrs: false,
};
</script>

<template>
  <b-table v-bind="$attrs" v-on="$listeners">
    <!-- This allows us to pass all slots and scoped slots to the bootstrap vue table's slots -->
    <slot v-for="slot in Object.keys($slots)" :slot="slot" :name="slot"></slot>
    <template v-for="slot in Object.keys($scopedSlots)" :slot="slot" slot-scope="scope">
      <slot :name="slot" v-bind="scope"></slot>
    </template>
  </b-table>
</template>
