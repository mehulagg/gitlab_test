<script>
import * as Documentation from '../components_documentation';
import GlExampleDisplay from './example_display.vue';

export default {
  components: {
    GlExampleDisplay,
  },
  props: {
    componentName: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      selectedExampleId: '',
    };
  },
  computed: {
    exampleGroups() {
      return (
        Documentation[
          Object.keys(Documentation).find(component => component.indexOf(this.componentName) > -1)
        ].examples || []
      );
    },
    firstExampleId() {
      if (
        this.exampleGroups &&
        this.exampleGroups.length > 0 &&
        this.exampleGroups[0].items &&
        this.exampleGroups[0].items.length > 0
      ) {
        return this.exampleGroups[0].items[0].id;
      }
      return null;
    },
  },
  mounted() {
    if (this.firstExampleId) {
      this.selectedExampleId = this.firstExampleId;
    }
  },
};
</script>

<template>
  <div>
    <b-form-select 
      v-if="exampleGroups && exampleGroups.length>0"
      v-model="selectedExampleId"
      class="mb-3"
    >
      <template v-for="exampleGroup in exampleGroups">
        <optgroup 
          :key="exampleGroup.title"
          :label="exampleGroup.name"
        ></optgroup>
        <template v-for="example in exampleGroup.items">
          <option
            :key="example.id"
            :value="example.id"
          >{{ example.name }}</option>
        </template>
      </template>
    </b-form-select>
    <gl-example-display 
      v-if="selectedExampleId" 
      :example-name="selectedExampleId"
    />
  </div>
</template>
