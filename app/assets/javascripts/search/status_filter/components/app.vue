<script>
  import { GlDropdown, GlDropdownItem, GlDropdownDivider } from '@gitlab/ui';

  export default {
    name: 'StatusFilter',
    components: {
      GlDropdown,
      GlDropdownItem,
      GlDropdownDivider
    }
  }
</script>

<template>
  <gl-dropdown text="Some dropdown">
    <gl-dropdown-item>{{ __("First item") }}</gl-dropdown-item>
    <gl-dropdown-item>{{ __("Second item") }}</gl-dropdown-item>
    <gl-dropdown-divider />
    <gl-dropdown-item>{{ __("Third item") }}</gl-dropdown-item>
    <gl-dropdown-item>{{ __("Fourth item") }}</gl-dropdown-item>
  </gl-dropdown>
</template>
