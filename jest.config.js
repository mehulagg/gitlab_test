const IS_EE = require('./config/helpers/is_ee_env');

const reporters = ['default'];

// To have consistent date time parsing both in local and CI environments we set
// the timezone of the Node process. https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/27738
process.env.TZ = 'GMT';

if (process.env.CI) {
  reporters.push([
    'jest-junit',
    {
      output: './junit_jest.xml',
    },
  ]);
}

let testMatch = ['<rootDir>/spec/frontend/**/*_spec.js', '<rootDir>/ee/spec/frontend/**/*_spec.js'];

// workaround for eslint-import-resolver-jest only resolving in test files
// see https://github.com/JoinColony/eslint-import-resolver-jest#note
const isESLint = module.parent.filename.includes('/eslint-import-resolver-jest/');
if (isESLint) {
  testMatch = testMatch.map(path => path.replace('_spec.js', ''));
}

// eslint-disable-next-line import/no-commonjs
module.exports = {
  testMatch,
  moduleFileExtensions: ['js', 'json', 'vue'],
  moduleNameMapper: {
    '^~(/.*)$': '<rootDir>/app/assets/javascripts$1',
    '^ee(/.*)$': '<rootDir>/ee/app/assets/javascripts$1',
    '^ee_component(/.*)$': IS_EE
      ? '<rootDir>/ee/app/assets/javascripts$1'
      : '<rootDir>/app/assets/javascripts/vue_shared/components/empty_component.js',
    '^ee_else_ce(/.*)$': IS_EE
      ? '<rootDir>/ee/app/assets/javascripts$1'
      : '<rootDir>/app/assets/javascripts$1',
    '^helpers(/.*)$': '<rootDir>/spec/frontend/helpers$1',
    '^vendor(/.*)$': '<rootDir>/vendor/assets/javascripts$1',
    '\\.(jpg|jpeg|png|svg)$': '<rootDir>/spec/frontend/__mocks__/file_mock.js',
    'emojis(/.*).json': '<rootDir>/fixtures/emojis$1.json',
    '^spec/test_constants$': '<rootDir>/spec/frontend/helpers/test_constants',
  },
  collectCoverageFrom: ['<rootDir>/app/assets/javascripts/**/*.{js,vue}'],
  coverageDirectory: '<rootDir>/coverage-frontend/',
  coverageReporters: ['json', 'lcov', 'text-summary', 'clover'],
  cacheDirectory: '<rootDir>/tmp/cache/jest',
  modulePathIgnorePatterns: ['<rootDir>/.yarn-cache/'],
  reporters,
  setupFilesAfterEnv: ['<rootDir>/spec/frontend/test_setup.js'],
  restoreMocks: true,
  transform: {
    '^.+\\.(gql|graphql)$': 'jest-transform-graphql',
    '^.+\\.js$': 'babel-jest',
    '^.+\\.vue$': 'vue-jest',
  },
  transformIgnorePatterns: ['node_modules/(?!(@gitlab/ui)/)'],
  timers: 'fake',
  testEnvironment: '<rootDir>/spec/frontend/environment.js',
  testEnvironmentOptions: {
    IS_EE,
  },
};

const karmaTestFile = process.argv.find(arg => arg.includes('spec/javascripts/'));
if (karmaTestFile) {
  console.error(`
Files in spec/javascripts/ and ee/spec/javascripts need to be run with Karma.
Please use the following command instead:

yarn karma -f ${karmaTestFile}

`);
  process.exit(1);
}
