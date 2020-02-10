# frozen_string_literal: true

module API
  module Defaults
    extend ActiveSupport::Concern

    included do
      helpers do
        def authenticate!
          JWT.decode(params[:user][:access_token], $secret[:api_hmac_secret], true, { :algorithm => 'HS256' })
          @access_token = AccessToken.where(token: params[:user][:access_token]).first
          if @access_token.present?
            @current_user = @access_token.user
          else
            respond_error(440, 'Invalid session.')
          end
        rescue JWT::ExpiredSignature
          access_token = AccessToken.where(token: params[:user][:access_token]).first
          access_token.destroy if access_token.present?
          respond_error(440, 'Session expired.')
        rescue
          respond_error(440, 'Invalid session.')
        end

        def error_message(object)
          object.errors.full_messages.uniq.join(',')
        end

        def respond(code = nil, data = nil)
          status code if code
          body data if data
        end

        def respond_error(code = nil, message = '')
          error!(message, code)
        end

        def pagination_data(collection)
          {
            previous_page: collection.previous_page,
            current_page: collection.current_page,
            next_page: collection.next_page,
            total_pages: collection.total_pages,
            total_count: collection.total_entries
          }
        end

        def get_timestamp(date_time)
          return if date_time.nil?

          date_time.strftime('%s%L').to_i
        end

        def full_name(data)
          "#{data.first_name} #{data.last_name}"
        end
      end
    end
  end
end
