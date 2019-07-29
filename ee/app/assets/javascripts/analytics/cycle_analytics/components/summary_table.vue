<script>
export default {
  name: 'SummaryTable',
  props: {
    items: {
      type: Array,
      required: true,
    },
  },
};
</script>
<template>
  <div class="wrapper mt-3">
    <div class="card">
      <div class="card-header font-weight-bold">{{ __('Recent Activity') }}</div>
      <div class="content-block">
        <div class="container-fluid">
          <div class="row">
            <div class="col-sm-3" />
            <div class="col-sm-3 col-12 column text-center" v-for="item in items" :key="item.title">
              <h3 class="header">{{ item.value }}</h3>
              <p class="text">{{ item.title }}</p>
            </div>
            <div class="col-sm-3" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
