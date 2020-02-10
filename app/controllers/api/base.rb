# frozen_string_literal: true

module API
  class Base < Grape::API
    mount API::V1::Base

    add_swagger_documentation mount_path: '/api_docs',
                              api_version: 'v1',
                              info: {
                                title: "Twitter API's",
                                description: "API's available for Twitter users"
                              }
  end
end
