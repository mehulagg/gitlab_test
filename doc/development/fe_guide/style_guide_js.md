# JavaScript Style Guide

We defer to [Airbnb][airbnb-js-style-guide] on most style-related
conventions and enforce them with eslint.

See [our current .eslintrc](https://gitlab.com/gitlab-org/gitlab/blob/master/.eslintrc.yml) for specific rules and patterns.

## ESlint

1. **Never** disable eslint rules unless you have a good reason.
   You may see a lot of legacy files with `/* eslint-disable some-rule, some-other-rule */`
   at the top, but legacy files are a special case.  Any time you develop a new feature or
   refactor an existing one, you should abide by the eslint rules.

1. **Never Ever EVER** disable eslint globally for a file

   ```javascript
   // bad
   /* eslint-disable */

   // better
   /* eslint-disable some-rule, some-other-rule */

   // best
   // nothing :)
   ```

1. If you do need to disable a rule for a single violation, try to do it as locally as possible

   ```javascript
   // bad
   /* eslint-disable no-new */

   import Foo from 'foo';

   new Foo();

   // better
   import Foo from 'foo';

   // eslint-disable-next-line no-new
   new Foo();
   ```

1. There are few rules that we need to disable due to technical debt. Which are:
   1. [no-new](https://eslint.org/docs/rules/no-new)
   1. [class-methods-use-this](https://eslint.org/docs/rules/class-methods-use-this)

1. When they are needed _always_ place ESlint directive comment blocks on the first line of a script,
   followed by any global declarations, then a blank newline prior to any imports or code.

   ```javascript
   // bad
   /* global Foo */
   /* eslint-disable no-new */
   import Bar from './bar';

   // good
   /* eslint-disable no-new */
   /* global Foo */

   import Bar from './bar';
   ```

1. **Never** disable the `no-undef` rule. Declare globals with `/* global Foo */` instead.

1. When declaring multiple globals, always use one `/* global [name] */` line per variable.

   ```javascript
   // bad
   /* globals Flash, Cookies, jQuery */

   // good
   /* global Flash */
   /* global Cookies */
   /* global jQuery */
   ```

1. Use up to 3 parameters for a function or class. If you need more accept an Object instead.

   ```javascript
   // bad
   fn(p1, p2, p3, p4) {}

   // good
   fn(options) {}
   ```

## Modules, Imports, and Exports

1. Use ES module syntax to import modules

   ```javascript
   // bad
   const SomeClass = require('some_class');

   // good
   import SomeClass from 'some_class';

   // bad
   module.exports = SomeClass;

   // good
   export default SomeClass;
   ```

   Import statements are following usual naming guidelines, for example object literals use camel case:

   ```javascript
   // some_object file
   export default {
     key: 'value',
   };

   // bad
   import ObjectLiteral from 'some_object';

   // good
   import objectLiteral from 'some_object';
   ```

1. Relative paths: when importing a module in the same directory, a child
   directory, or an immediate parent directory prefer relative paths.  When
   importing a module which is two or more levels up, prefer either `~/` or `ee/`.

   In **app/assets/javascripts/my-feature/subdir**:

   ```javascript
   // bad
   import Foo from '~/my-feature/foo';
   import Bar from '~/my-feature/subdir/bar';
   import Bin from '~/my-feature/subdir/lib/bin';

   // good
   import Foo from '../foo';
   import Bar from './bar';
   import Bin from './lib/bin';
   ```

   In **spec/javascripts**:

   ```javascript
   // bad
   import Foo from '../../app/assets/javascripts/my-feature/foo';

   // good
   import Foo from '~/my-feature/foo';
   ```

   When referencing an **EE component**:

   ```javascript
   // bad
   import Foo from '../../../../../ee/app/assets/javascripts/my-feature/ee-foo';

   // good
   import Foo from 'ee/my-feature/foo';
   ```

1. Avoid using IIFE. Although we have a lot of examples of files which wrap their
   contents in IIFEs (immediately-invoked function expressions),
   this is no longer necessary after the transition from Sprockets to webpack.
   Do not use them anymore and feel free to remove them when refactoring legacy code.

1. Avoid adding to the global namespace.

   ```javascript
   // bad
   window.MyClass = class { /* ... */ };

   // good
   export default class MyClass { /* ... */ }
   ```

1. Side effects are forbidden in any script which contains export

   ```javascript
   // bad
   export default class MyClass { /* ... */ }

   document.addEventListener("DOMContentLoaded", function(event) {
     new MyClass();
   }
   ```

## Data Mutation and Pure functions

1. Strive to write many small pure functions, and minimize where mutations occur.

   ```javascript
   // bad
   const values = {foo: 1};

   function impureFunction(items) {
     const bar = 1;

     items.foo = items.a * bar + 2;

     return items.a;
   }

   const c = impureFunction(values);

   // good
   var values = {foo: 1};

   function pureFunction (foo) {
     var bar = 1;

     foo = foo * bar + 2;

     return foo;
   }

   var c = pureFunction(values.foo);
    ```

1. Avoid constructors with side-effects.
   Although we aim for code without side-effects we need some side-effects for our code to run.

   If the class won't do anything if we only instantiate it, it's ok to add side effects into the constructor (_Note:_ The following is just an example. If the only purpose of the class is to add an event listener and handle the callback a function will be more suitable.)

   ```javascript
   // Bad
   export class Foo {
     constructor() {
       this.init();
     }
     init() {
       document.addEventListener('click', this.handleCallback)
     },
     handleCallback() {

     }
   }

   // Good
   export class Foo {
     constructor() {
       document.addEventListener()
     }
     handleCallback() {
     }
   }
   ```

   On the other hand, if a class only needs to extend a third party/add event listeners in some specific cases, they should be initialized outside of the constructor.

1. Prefer `.map`, `.reduce` or `.filter` over `.forEach`
   A forEach will most likely cause side effects, it will be mutating the array being iterated. Prefer using `.map`,
   `.reduce` or `.filter`

   ```javascript
   const users = [ { name: 'Foo' }, { name: 'Bar' } ];

   // bad
   users.forEach((user, index) => {
     user.id = index;
   });

   // good
   const usersWithId = users.map((user, index) => {
     return Object.assign({}, user, { id: index });
   });
   ```

## Parse Strings into Numbers

1. `parseInt()` is preferable over `Number()` or `+`

   ```javascript
   // bad
   +'10' // 10

   // good
   Number('10') // 10

   // better
   parseInt('10', 10);
   ```

## CSS classes used for JavaScript

1. If the class is being used in Javascript it needs to be prepend with `js-`

   ```html
   // bad
   <button class="add-user">
     Add User
   </button>

   // good
   <button class="js-add-user">
     Add User
   </button>
   ```

[airbnb-js-style-guide]: https://github.com/airbnb/javascript
[eslintrc]: https://gitlab.com/gitlab-org/gitlab/blob/master/.eslintrc
[eslint-plugin-vue]: https://github.com/vuejs/eslint-plugin-vue
[eslint-plugin-vue-rules]: https://github.com/vuejs/eslint-plugin-vue#bulb-rules
[vue-order]: https://github.com/vuejs/eslint-plugin-vue/blob/master/docs/rules/order-in-components.md
