<script>
import EditorLite from './dag_editor.vue';
import Dag from './dag.vue';
import jsyaml from 'js-yaml';

export default {
  components: {
    EditorLite,
    Dag,
  },
  data() {
    return {
      graphData: {},
    };
  },
  methods: {
    updateDagData(yamlString) {
      const jsonData = jsyaml.load(yamlString);
      // Get all the stages name
      const jobNames = Object.keys(jsonData);
      const stages = Array.from(new Set(jobNames.map(job => jsonData[job].stage)));
      // Get all the jobs for each stage
      const arrayOfJobsByStage = stages.map(val => {
        return jobNames.filter(job => {
          return jsonData[job].stage === val;
        });
      });

      // Make the final structure where each stage is an object in the list
      // and th jobs are in the groups
      // Go through each job, and make a list of all jobs in that stage
      const dagLikeStructure = stages.map((stage, index) => {
        const stageJobs = arrayOfJobsByStage[index];
        return {
          name: stage,
          groups: stageJobs.map(job => {
            return { name: job, jobs: [{ ...jsonData[job] }] };
          }),
        };
      });

      this.graphData = { stages: dagLikeStructure };
    },
  },
};
</script>
<template>
  <div id="dag-editor-preview">
    <editor-lite @input="updateDagData" />
    <dag v-if="Object.keys(graphData).length > 0" :graph-data="graphData" />
  </div>
</template>
