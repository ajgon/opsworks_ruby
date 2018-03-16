# frozen_string_literal: true

module Drivers
  module Source
    module Scm
      class Base < Drivers::Source::Base
        def fetch(deploy_context)
          deploy_context.scm_provider(adapter.constantize)

          out.each do |scm_key, scm_value|
            scm_key = :repository if scm_key == :url
            deploy_context.send(scm_key, scm_value) if deploy_context.respond_to?(scm_key)
          end
        end
      end
    end
  end
end
