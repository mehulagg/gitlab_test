import Vue from 'vue';
import ApprovalsBody from 'ee/vue_merge_request_widget/components/approvals/single_rule/approvals_body.vue';
import {
  OPTIONAL,
  OPTIONAL_CAN_APPROVE,
} from 'ee/vue_merge_request_widget/components/approvals/messages';

describe('Approvals Body Component', () => {
  let vm;
  const initialData = {
    mr: {
      isOpen: true,
    },
    service: {},
    suggestedApprovers: [{ name: 'Approver 1' }],
    userCanApprove: false,
    userHasApproved: true,
    approvedBy: [],
    approvalsLeft: 1,
    approvalsOptional: false,
    pendingAvatarSvg: '<svg></svg>',
    checkmarkSvg: '<svg></svg>',
  };

  beforeEach(() => {
    setFixtures('<div id="mock-container"></div>');

    const ApprovalsBodyComponent = Vue.extend(ApprovalsBody);

    vm = new ApprovalsBodyComponent({
      el: '#mock-container',
      propsData: initialData,
    });
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('should correctly set component props', () => {
    Object.keys(vm).forEach(propKey => {
      if (initialData[propKey]) {
        expect(vm[propKey]).toBe(initialData[propKey]);
      }
    });
  });

  describe('Computed properties', () => {
    describe('approvalsRequiredStringified', () => {
      it('should display the correct string for 1 possible approver', () => {
        const correctText = 'Requires 1 more approval by';

        expect(vm.approvalsRequiredStringified).toBe(correctText);
      });

      it('should display the correct string for 2 possible approvers', done => {
        const correctText = 'Requires 2 more approvals by';

        vm.approvalsLeft = 2;
        vm.suggestedApprovers.push({ name: 'Approver 2' });

        Vue.nextTick(() => {
          expect(vm.approvalsRequiredStringified).toBe(correctText);
          done();
        });
      });

      it('should display the correct string for 0 approvals required', done => {
        const correctText = OPTIONAL;

        vm.approvalsOptional = true;

        Vue.nextTick(() => {
          expect(vm.approvalsRequiredStringified).toBe(correctText);
          done();
        });
      });

      it('should display the correct string for 0 approvals required and if the user is able to approve', done => {
        const correctText = OPTIONAL_CAN_APPROVE;

        vm.approvalsOptional = true;
        vm.userCanApprove = true;

        Vue.nextTick(() => {
          expect(vm.approvalsRequiredStringified).toBe(correctText);
          done();
        });
      });

      it('shows the "Merge request approved" copy when there are enough approvals in place', done => {
        vm.approvalsLeft = 0;

        Vue.nextTick(() => {
          expect(vm.approvalsRequiredStringified).toBe('Merge request approved');
          done();
        });
      });

      it('shows the correct copy when there are enough approvals in place but user can approve', done => {
        vm.approvalsLeft = 0;
        vm.userCanApprove = true;

        Vue.nextTick(() => {
          expect(vm.approvalsRequiredStringified).toBe(
            'Merge request approved; you can approve additionally',
          );
          done();
        });
      });

      it('shows the "Requires 1 more approval" without by when no suggested approvals are available', done => {
        const correctText = 'Requires 1 more approval';
        vm.suggestedApprovers = [];

        Vue.nextTick(() => {
          expect(vm.approvalsRequiredStringified).toBe(correctText);
          done();
        });
      });

      it('shows the "Requires 2 more approvals" without by when no suggested approvals are available', done => {
        const correctText = 'Requires 2 more approvals';

        vm.approvalsLeft = 2;
        vm.suggestedApprovers = [];

        Vue.nextTick(() => {
          expect(vm.approvalsRequiredStringified).toBe(correctText);
          done();
        });
      });
    });

    describe('showApproveButton', () => {
      it('should not be true when the user cannot approve', done => {
        vm.userCanApprove = false;
        vm.userHasApproved = true;
        Vue.nextTick(() => {
          expect(vm.showApproveButton).toBe(false);
          done();
        });
      });

      it('should be true when the user can approve', done => {
        vm.userCanApprove = true;
        vm.userHasApproved = false;
        Vue.nextTick(() => {
          expect(vm.showApproveButton).toBe(true);
          done();
        });
      });
    });

    describe('approveButtonText', () => {
      it('The approve button should have the "Approve" text', done => {
        vm.approvalsLeft = 1;
        vm.userHasApproved = false;
        vm.userCanApprove = true;

        Vue.nextTick(() => {
          expect(vm.approveButtonText).toBe('Approve');
          done();
        });
      });

      it('The approve button should have the "Add approval" text', done => {
        vm.approvalsLeft = 0;
        vm.userHasApproved = false;
        vm.userCanApprove = true;

        Vue.nextTick(() => {
          expect(vm.approveButtonText).toBe('Add approval');
          done();
        });
      });
    });
  });
});
