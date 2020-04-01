export const failedIssue = {
  name:
    'The accessibility scanning found 2 errors of the following type: WCAG2AA.Principle4.Guideline4_1.4_1_2.H91.A.NoContent',
  code: 'WCAG2AA.Principle4.Guideline4_1.4_1_2.H91.A.NoContent',
  status: 'failed',
  className: 'spec.test_spec',
  parsedTECHSCode: 'H91',
  learnMoreUrl: 'https://www.w3.org/TR/WCAG20-TECHS/H91.html',
};

export const newIssuesReport = {
  status: 'success',
  summary: {
    total: 0,
    errors: 0,
    notes: 0,
    warnings: 1,
  },
  new_warnings: [
    {
      name:
        'The accessiblity scanning found 2 errors of the following type: WCAG2AA.Principle4.Guideline4_1.4_1_2.H91.A.NoContent',
      code: 'WCAG2AA.Principle4.Guideline4_1.4_1_2.H91.A.NoContent',
      message:
        'Anchor element found with a valid href attribute, but no link content has been supplied.',
      status: 'failed',
      classname: 'spec.test_spec',
    },
  ],
  resolved_warnings: [],
  existing_warnings: [],
  new_errors: [],
  resolved_errors: [],
  existing_errors: [],
  new_notes: [],
  resolved_notes: [],
  existing_notes: [],
};
