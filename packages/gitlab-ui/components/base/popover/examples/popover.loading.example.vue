<template>
  <div>
    <gl-button id="pop-basic">Popover Button</gl-button>
    <gl-popover 
      target="pop-basic"
      placement="top"
      title="My popover"
      triggers="hover focus"
      show
    >
      <gl-skeleton-loading />
    </gl-popover>
  </div>
</template>
