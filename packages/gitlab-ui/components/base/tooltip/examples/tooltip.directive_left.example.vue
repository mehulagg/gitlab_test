<template>
  <div id="tooltipcontainer" class="d-flex align-items-center justify-content-center p-3">
    <gl-button 
      v-gl-tooltip:tooltipcontainer.left
      title="some tooltip text"
    >
      Testbutton
    </gl-button>
  </div>
</template>
