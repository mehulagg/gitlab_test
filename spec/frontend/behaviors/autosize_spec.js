import '~/behaviors/autosize';

function load() {
  document.dispatchEvent(new Event('load'));
}

describe('Autosize behavior', () => {
  beforeEach(() => {
    setFixtures('<textarea class="js-autosize" style="resize: vertical"></textarea>');
  });

  it('does not overwrite the resize property', () => {
    load();

    expect(document.querySelector('textarea')).toHaveCss({
      resize: 'vertical',
    });
  });
});
