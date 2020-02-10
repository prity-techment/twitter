# frozen_string_literal: true

module API
  module V1
    module Helpers
      module ParamsHelpers
        extend Grape::API::Helpers

        params :authentication_params do
          requires :user, type: Hash do
            requires :access_token, type: String, desc: 'Access Token'
          end
        end

        params :pagination_params do
          optional :page, type: Integer, except_values: [0]
          optional :per_page, type: Integer, except_values: [0]
        end
      end
    end
  end
end
