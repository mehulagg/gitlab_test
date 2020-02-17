# frozen_string_literal: true

module Gitlab
  module Ci
    class JwtAuth
      def self.jwt_for_job(job, ttl: 60)
        now = Time.now.to_i
        payload = {
          # Issuer
          iss: Settings.gitlab.host,
          # Issued at
          iat: now,
          # Expiry at
          exp: now + ttl,
          # Subject
          sub: job.project.id.to_s,
          # Namespace
          nid: (job.project.namespace.type.presence || 'user').downcase + ':' + job.project.namespace.id.to_s,
          # User Id
          uid: job.user_id.to_s,
          # Project Id
          pid: job.project_id.to_s,
          # Job Id
          jid: job.id.to_s,
          # Ref name
          ref: job.ref
        }

        JWT.encode(
          payload,
          OpenSSL::PKey::RSA.new(Rails.application.secrets.openid_connect_signing_key),
          "RS256"
        )
      end
    end
  end
end
