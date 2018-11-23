<template>
  <div>
    <gl-button id="pop-basic">Popover Button</gl-button>
    <gl-popover 
      target="pop-basic"
      placement="top"
      title="User information"
      triggers="hover focus"
      show
    >
      <p><strong>This is fully formatted</strong> content, including components</p>
      <gl-progress-bar :value="75" />
      <p>The popover is automatically shown for visual regression testing</p>
    </gl-popover>
  </div>
</template>
