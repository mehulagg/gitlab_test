context('Anonymous user on Boards page', () => {
  let responses = {};

  beforeEach(() => {
    if (Cypress.env('SAVE_FIXTURES')) {
      cy.server({
        onResponse: response => {
          responses[response.url] = response.body;
        }
      });
      cy.route({
        method: 'GET',
        url: '*',
      });
    }

    cy.visit('http://localhost:3000/gitlab-org/gitlab-test/-/boards');
  });

  after(() => {
    // In record mode, save gathered XHR data to local JSON file
    if (Cypress.env('SAVE_FIXTURES')) {
      Object.keys(responses).forEach(key => {
        const baseUrl = 'http://localhost:3000';
        const filePath = key.replace(baseUrl, 'cypress/fixtures');

        if (!responses[key]) {
          cy.log('--- empty response for: ', key);
        } else {
          cy.writeFile(filePath, responses[key]);
        }
      });
    }
  });

  it('opens sidebar when clicking issue title', () => {
    const issueTitle = 'Consequatur voluptatem in fugit est ullam dolor in aliquam sed vitae.';
    cy.get('[data-qa-selector="board_card"]').first().click();

    cy.get('.right-sidebar').should('contain.text', issueTitle);
  });
});
