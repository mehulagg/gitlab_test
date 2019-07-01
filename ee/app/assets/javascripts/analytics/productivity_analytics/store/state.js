export default () => ({
  chartEndpoint: null,
  filters: {
    // groupId: null,
    groupId: 123,
  },
  charts: {
    main: {
      isLoading: false,
      hasError: false,
      data: null,
      // selected: null,
      selected: ['1'],
    },
  },
});
