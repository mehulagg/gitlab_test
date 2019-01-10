### ECharts Wrapper

The chart component is a Vue component wrapper around [ECharts]. The chart component accepts width and height props in order to allow the user to make it responsive, but it is not responsive by default.

> Note: In every case there should be a specific component for each type of chart (i.e. Line, Area, Bar, etc.). This component should only need to be used by chart type components within GitLab UI as opposed to being used directly within any other codebase.

### EChart Lifecycle

This component emits the following events during the ECharts lifecycle:

- `created`: emitted after calling `echarts.init`
- `updated`: emitted after calling `echarts.setOption`

In all cases, the event payload is the echart instance.

[echarts]: https://ecomfe.github.io/echarts-doc/public/
