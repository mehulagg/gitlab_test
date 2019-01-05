<template>
  <gl-table :items="$options.items" :fields="$options.fields" />
</template>

<script>
export default {
  fields: [
    {
      key: 'column_one',
      label: 'Column One',
    },
    {
      key: 'col_2',
      label: 'Column 2',
    },
  ],
  items: [
    {
      column_one: 'test',
      col_2: 1234,
    },
    {
      column_one: 'test2',
      col_2: 5678,
    },
    {
      column_one: 'test3',
      col_2: 9101,
    },
  ],
};
</script>
