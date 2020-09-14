/**
 * Creates an array of objects matching the shape of a GraphQl
 * SastCiConfigurationEntity.
 *
 * @param {number} count - The number of entities to create.
 * @param {Object} [changes] - Object representing changes to apply to the
 *     generated entities.
 * @returns {Object[]}
 */
export const makeEntities = (count, changes) =>
  [...Array(count).keys()].map(i => ({
    defaultValue: `defaultValue${i}`,
    description: `description${i}`,
    field: `field${i}`,
    label: `label${i}`,
    type: 'string',
    value: `defaultValue${i}`,
    ...changes,
  }));

/**
 * Creates an array of objects matching the shape of a GraphQl
 * SastCiConfigurationAnalyzersEntity.
 *
 * @param {number} count - The number of entities to create.
 * @param {Object} [changes] - Object representing changes to apply to the
 *     generated entities.
 * @returns {Object[]}
 */
export const makeAnalyzerEntities = (count, changes) =>
  [...Array(count).keys()].map(i => ({
    name: `nameValue${i}`,
    label: `label${i}`,
    description: `description${i}`,
    enabled: true,
    ...changes,
  }));
