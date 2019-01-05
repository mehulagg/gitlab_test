<template>
  <gl-table :items="$options.items" :fields="$options.fields">
    <template slot="custom_markup" slot-scope="items">
      <div class="text-primary">
        {{ items.item.col_2 }}
      </div>
    </template>
  </gl-table>
</template>

<script>
export default {
  fields: [
    {
      key: 'column_one',
      label: 'Column One',
    },
    {
      key: 'custom_markup',
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
