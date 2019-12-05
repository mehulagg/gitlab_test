import { Selector } from 'testcafe';

fixture `Boards test`
  .page('http://localhost:3001/root/metrics/-/boards');

test('Clicking card shows title in sidebar', async t => {
  await t.click('[data-qa-selector="board_card"]')

  await t.expect(Selector('.issuable-header-text').innerText).eql('test\n#2');
});
