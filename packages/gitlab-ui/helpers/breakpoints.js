export const breakpoints = {
  xl: 1200,
  lg: 992,
  md: 768,
  sm: 576,
  xs: 0,
};

const BreakpointInstance = {
  windowWidth: () => window.innerWidth,
  getBreakpointSize() {
    const windowWidth = this.windowWidth();

    const breakpoint = Object.keys(breakpoints).find(key => windowWidth > breakpoints[key]);

    return breakpoint;
  },
};

export default BreakpointInstance;
