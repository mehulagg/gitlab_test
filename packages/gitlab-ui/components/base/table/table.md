**Using Fields prop**

To ensure we internationalize Field Labels, always pass an array of objects for the `fields` prop.

```
// bad - shorthand way
fields: ['column_one', 'col_2']

// good - using translations for column names
fields: [
  {
    key: 'column_one',
    label: __('Column One'),
  },
  {
    key: 'col_2',
    label: __('Column 2'),
  },
];
```
