<script>
export default {
  name: 'ProductivityAnalayticsEmptyState',
  props: {
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div class="row empty-state js-empty-state">
    <div class="col-12">
      <div class="svg-content svg-250"><img :src="emptyStateSvgPath" /></div>
    </div>
    <div class="col-12">
      <div class="text-content">
        <h4>
          {{
            s__('Productivity analytics can help identify the problems that are delaying your team')
          }}
        </h4>

        <p>
          {{
            s__(
              'Start by choosing a group to start exploring the merge requests in that group. You can then proceed to filter by projects, labels, milestones, authors and assignees.',
            )
          }}
        </p>
      </div>
    </div>
  </div>
</template>
