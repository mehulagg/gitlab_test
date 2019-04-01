import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import eventHub from '~/vue_merge_request_widget/event_hub';
import ApprovalsAuth from 'ee/vue_merge_request_widget/components/approvals/multiple_rule/approvals_auth.vue';
import { APPROVE_ERROR, APPROVAL_PASSWORD_INVALID } from 'ee/vue_merge_request_widget/components/approvals/messages';

const localVue = createLocalVue();
const testApprovals = () => ({
    force_auth_for_approval: true,
});
const tick = () => Promise.resolve().then(localVue.nextTick);
const waitForTick = done =>
    tick()
        .then(done)
        .catch(done.fail);

describe('Approval auth component', () => {
    let wrapper;
    let service;
    let mr;
    let refreshRules;
    const findAction = () => wrapper.find(GlButton);
    let createFlash;

    const createComponent = (props = {}) => {
        wrapper = shallowMount(localVue.extend(ApprovalsAuth), {
           propsData: {
               approvalText: "approval",
               refreshRules,
               service,
               mr,
                ...props,
           },
            localVue,
            sync: false,
        });
    };

    beforeEach(() => {
        service = jasmine.createSpyObj('MRWidgetService', {
            approveMergeRequestWithAuth: Promise.resolve(testApprovals()),
        });
        mr = {
            approvals: testApprovals(),
            ...jasmine.createSpyObj('Store', ['setApprovals', 'setApprovalRules']),
        };
        refreshRules = jasmine.createSpy('refreshRules', () => {});
        createComponent();
        createFlash = spyOnDependency(ApprovalsAuth, 'createFlash');
        spyOn(eventHub, '$emit');
    });

    afterEach(() => {
        wrapper.destroy();
        wrapper = null;
    });

    describe('when created', () => {

        it('approved button is rendered', () => {
            expect(wrapper.findAll(GlButton).length).toBe(1);
            expect(wrapper.find('input').exists()).toBe(false);
        });
    });

    describe('when show password is clicked', () => {
        beforeEach(done => {
            findAction().vm.$emit('click');
            waitForTick(done);
        });

        it('password prompt and actions are rendered', () => {
            expect(wrapper.findAll(GlButton).length).toBe(2);
            expect(wrapper.find('input').exists()).toBe(true);
        });

        describe('when cancel is clicked', () => {
            beforeEach(done => {
                wrapper.findAll(GlButton).at(1).vm.$emit('click');
                waitForTick(done);
            });

            it('approve button is rendered', () => {
                expect(wrapper.findAll(GlButton).length).toBe(1);
                expect(wrapper.find('input').exists()).toBe(false);
            });
        });
    });

    describe('when approve action is clicked', () => {
       beforeEach(done => {
           createComponent();
           // show password prompt
           findAction().vm.$emit('click');
           // approve
           findAction().vm.$emit('click');
           waitForTick(done);
       });

       it('shows loading icon', done => {
           service.approveMergeRequestWithAuth.and.callFake(() => new Promise(() => {}));
           const action = findAction();

           expect(action.find(GlLoadingIcon).exists()).toBe(false);

           action.vm.$emit('click');

           tick()
               .then(() => {
                   expect(action.find(GlLoadingIcon).exists()).toBe(true);
               })
               .then(done)
               .catch(done.fail);
       });

        describe('and after loading', () => {
            beforeEach(done => {
                findAction().vm.$emit('click');
                waitForTick(done);
            });

            it('calls service approve with auth', () => {
                expect(service.approveMergeRequestWithAuth).toHaveBeenCalled();
            });

            it('emits to eventHub', () => {
                expect(eventHub.$emit).toHaveBeenCalledWith('MRWidgetUpdateRequested');
            });

            it('calls store setApprovals', () => {
                expect(mr.setApprovals).toHaveBeenCalledWith(testApprovals());
            });

            it('calls refreshRules', () => {
                expect(refreshRules).toHaveBeenCalled();
            })
        });

        describe('and invalid password error', () => {
            beforeEach(done => {
                const err = new Error();
                err.response = { status: 401 };
                service.approveMergeRequestWithAuth.and.returnValue(Promise.reject(err));
                findAction().vm.$emit('click');
                waitForTick(done);
            });

            it('flashes invalid password message', () => {
                expect(createFlash).toHaveBeenCalledWith(APPROVAL_PASSWORD_INVALID);
            });
        });

        describe('and other error', () => {
            beforeEach(done => {
                const err = new Error();
                err.response = { status: 500 };
                service.approveMergeRequestWithAuth.and.returnValue(Promise.reject(err));
                findAction().vm.$emit('click');
                waitForTick(done);
            });

            it('flashes generic error message', () => {
                expect(createFlash).toHaveBeenCalledWith(APPROVE_ERROR);
            });
        });
    });
});
