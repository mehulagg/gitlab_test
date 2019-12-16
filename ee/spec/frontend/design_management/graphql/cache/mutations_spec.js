import updateCache from 'ee/design_management/graphql/cache';

const mockStore = {
  readQuery: jest.fn(),
  writeQuery: jest.fn(),
};

describe('updateCache', () => {
  it('reads from cache, performs transformation, and writes to cache', () => {
    const mockTransform = jest.fn();
    updateCache(mockStore, {}, {}, mockTransform);
    expect(mockStore.readQuery).toHaveBeenCalled();
    expect(mockStore.writeQuery).toHaveBeenCalled();
    expect(mockTransform).toHaveBeenCalled();
  });
});
