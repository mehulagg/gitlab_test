import { generateAnnotationsSeries } from '~/monitoring/components/charts/annotations';
import { deploymentData } from '../../mock_data';

describe('annotations spec', () => {
  describe('generateAnnotationsSeries', () => {
    it('with default options', () => {
      const annotations = generateAnnotationsSeries();

      expect(annotations).toEqual(
        expect.objectContaining({
          type: 'scatter',
          yAxisIndex: 1,
          data: [],
        }),
      );
    });

    it('when only deployments data is passed', () => {
      const annotations = generateAnnotationsSeries({ deployments: deploymentData });

      expect(annotations).toEqual(
        expect.objectContaining({
          type: 'scatter',
          yAxisIndex: 1,
          data: expect.any(Array),
        }),
      );

      annotations.data.forEach(annotation => {
        expect(annotation).toEqual(expect.any(Object));
      });

      expect(annotations.data).toHaveLength(deploymentData.length);
    });

    it('when deployments and annotations data is passed', () => {
      const annotations = generateAnnotationsSeries({
        deployments: deploymentData,
      });

      expect(annotations).toEqual(
        expect.objectContaining({
          type: 'scatter',
          yAxisIndex: 1,
          data: expect.any(Array),
        }),
      );

      expect(annotations.data).toHaveLength(deploymentData.length);
    });
  });
});
