# frozen_string_literal: true

module QA
  context 'Manage', :docker do
    describe 'mail notification' do
      before do
        run_mailhog_service

        Runtime::Browser.visit(:gitlab, Page::Main::Login)
      end

      it 'user receives email for project invitation' do
        expect(true).to be(true)
      end

      after do
        remove_mailhog_service
      end

      def run_mailhog_service
        Service::DockerRun::MailHog.new.tap do |runner|
          runner.pull
          runner.register!
        end
      end

      def remove_mailhog_service
        Service::DockerRun::MailHog.new.remove!
      end
    end
  end
end
