<script>
  import GlButton from '@gitlab/ui/dist/components/base/button/button';
  import GlCard from '@gitlab/ui/dist/components/base/card/card';
  import GlLink from '@gitlab/ui/dist/components/base/link/link';
  import GlAreaChart from '@gitlab/ui/dist/components/charts/area/area';

  const items = require('./../assets/mock');

  export default {
    components: {
      GlButton,
      GlCard,
      GlAreaChart,
      GlLink,
    },
    data() {
      return {
        chartData: [
          {
            name: 'Values',
            data: [
              [0, 5],
              [4, 3],
              [8, 10],
            ],
          },
        ],
        chartOptions:
          {
            series: [
              {
                type: 'scatter',
                data: [
                  [2, 5],
                  [6, 10],
                ],
              },
            ]
          }
      }
    },
    computed: {
      index() {
        return this.$route.params.id;
      },
      item() {
        return items[this.index];
      },
    },
    methods: {},
  }
</script>

<template>
  <div class="container mt-4">
    <div class="bb-1 p-3">
      <router-link to="/">
        Return to status overview
      </router-link>
    </div>
    <h3 class="my-3">{{item.title}}</h3>
    <h4 class="py-2">Summary</h4>
<!--    <markdown>{{item.description}}</markdown>-->
    <pre>{{item.description}}</pre>
    <gl-area-chart
      :data="chartData"
      :option="chartOptions"/>

    <h4 class="py-2">Comments</h4>

    <gl-card v-for="(comment, index) in item.history" :title="comment.date" :key="index">
      {{comment.comment}}
    </gl-card>
  </div>
</template>

<style scoped lang="scss">
  .test {
    margin-top: 20px;
  }
</style>
