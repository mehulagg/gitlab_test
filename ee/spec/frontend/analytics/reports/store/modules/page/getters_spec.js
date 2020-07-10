import * as getters from 'ee/analytics/reports/store/modules/page/getters';

describe('Reports page getters', () => {
  let state;

  afterEach(() => {
    state = null;
  });

  describe('displayChart', () => {
    it.each`
      isLoading | series              | expected
      ${true}   | ${[]}               | ${false}
      ${true}   | ${[{ foo: 'bar' }]} | ${false}
      ${false}  | ${[]}               | ${false}
      ${false}  | ${[{ foo: 'bar' }]} | ${true}
    `(
      'with isLoading=$isLoading and series=$series returns $expected',
      ({ isLoading, series, expected }) => {
        state = {
          isLoading,
          config: {
            chart: {
              series,
            },
          },
        };

        expect(getters.displayChart(state)).toBe(expected);
      },
    );
  });

  describe('chartYAxisTitle', () => {
    it('returns the chart y-axis title when present', () => {
      state = {
        config: {
          chart: {
            series: [
              {
                title: 'title',
              },
            ],
          },
        },
      };

      expect(getters.chartYAxisTitle(state)).toBe('title');
    });

    it('returns an empty string when the chart y-axis title is not present', () => {
      state = {};

      expect(getters.chartYAxisTitle(state)).toBe('');
    });
  });
});
