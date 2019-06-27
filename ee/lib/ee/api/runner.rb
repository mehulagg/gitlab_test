# frozen_string_literal: true

module EE
  module API
    module Runner
      extend ActiveSupport::Concern

      prepended do
        resource :jobs do
          desc 'Authorizes HTTP proxy requests'
          params do
            requires :id, type: Integer, desc: %q(Job's ID)
            requires :service, type: String, desc: %q(Service name running in the job to proxy to)
            optional :port, type: String, desc: %q(Service port running in the job to proxy to)
            requires :token, type: String, desc: %q(Service's authentication token)
            requires :domain, type: String, desc: %q(Service's proxy domain)
          end
          route :any, '/:id/proxy/authorize' do
            require_gitlab_workhorse!
            ::Gitlab::Workhorse.verify_api_request!(headers)

            job = ::Ci::Build.find(params[:id])
            # authorize! :create_build_service_proxy, job

            # FIXME Delete
            # job = ::Ci::Build.find(5160)
            # puts params
            unless job.valid_api_proxy_token?(params[:token], params[:domain])
              forbidden!('Invalid token')
            end

            # authorize! :create_build_service_proxy, job
            # FIXME Delete
            # runner_session = job.build_runner_session(url: "https://global.admin-me.com")

            service_spec = job.service_specification(service: params['service'], port: params['port'])

            puts service_spec.inspect

            forbidden!('Job has no session') if service_spec.nil?

            present ::Gitlab::Workhorse.service_request(service_spec)
            content_type ::Gitlab::Workhorse::INTERNAL_API_CONTENT_TYPE
          end
        end
      end
    end
  end
end
