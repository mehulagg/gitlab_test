<template>
  <gl-breadcrumb :items="items"/>
</template>

<script>
export default {
  data() {
    return {
      items: [
        {
          text: 'First Item',
          href: '#',
        },
        {
          text: 'Second Item',
          href: '#',
        },
        {
          text: 'Third Item',
          active: true,
        },
      ],
    };
  },
};
</script>
