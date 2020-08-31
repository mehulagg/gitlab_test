# frozen_string_literal: true

module QA
  context 'Create' do
    # Use Admin credentials as a workaround for a permissions bug
    # See https://gitlab.com/gitlab-org/gitlab/issues/13769
    describe 'Pull mirror a repository over HTTP', :requires_admin do
      it 'configures and syncs a (pull) mirrored repository with password auth', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/520' do
        raise "report this"
      end

      def masked_url(url)
        url.password = '*****'
        url.user = '*****'
        url
      end
    end
  end
end
