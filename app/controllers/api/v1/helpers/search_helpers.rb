# frozen_string_literal: true

# Conatins to get search query string of various models
module API
  module V1
    module Helpers
      module SearchHelpers
        extend Grape::API::Helpers

        def get_search_query_condition(search_params, model_name)
          search_condition = ''
          search = search_params.reject { |_k, v| v.nil? }
          if search.key?(:dorm)
            search[:dorms] = search[:dorm]
            search.delete('dorm')
          end
          search.each do |column_name, search_value|
            case column_name
            when 'shift_id'
              search_condition += "CAST(shifts.id AS TEXT) ILIKE '%#{search_value}%'"
            when 'grad_year'
              search_condition += "CAST(grad_year AS TEXT) ILIKE '%#{search_value}%'"
            when 'regions', 'dorms'
              if model_name == 'weights'
                region = Region.find_by(name: search_value)
                search_condition += "bags.region_id = #{region.id}"
              else
                search_value = search_value.downcase.gsub(' ', '_')
                search_condition += "#{column_name}.name ILIKE '%#{search_value}%'"
              end
            when 'name', 'sender_name', 'actor_name', 'owner_name'
              search_condition += "CONCAT_WS(' ', first_name, last_name) ILIKE '%#{search_value}%'"
            when 'barcode'
              search_condition += "bags.#{column_name} ILIKE '%#{search_value}%'"
            when 'room'
              search_condition += "users.#{column_name} ILIKE '%#{search_value}%'"
            when 'actor_phone_number', 'actor_email'
              search_condition += "users.#{column_name.remove('actor_')}  ILIKE '%#{search_value}%'"
            when 'account_types'
              search_value = search_value.titleize.gsub(' ', '').split(',')
              roles_mask_values = []
              search_value.each do |role|
                roles_mask_values << User.generate_mask_values(role)
              end
              search_condition += "roles_mask IN (#{roles_mask_values.join(',')})"
            when 'actor_id', 'owner_id', 'bag_id', 'shift_id', 'grad_year'
              search_condition += "(#{model_name}.#{column_name} = #{search_value})"
            when 'delayed_action'
              search_condition += '(flagged IS NOT NULL)' if search_value == 'display_all'
              search_condition += '(flagged = true)' if search_value == 'only_flagged'
              search_condition += '(flagged = false)' if search_value == 'not_flagged'
            when 'archived'
              search_condition += '(hidden IS NOT NULL)' if search_value == 'display_all'
              search_condition += '(hidden = true)' if search_value == 'only_archived'
              search_condition += '(hidden = false)' if search_value == 'not_archived'
            when 'status', 'action_error', 'error_type'
              if column_name == 'status' && model_name == 'announcements'
                search_condition += '(sent IS NOT NULL AND send_emails IS NOT NULL)' if search_value == 'display_all'
                search_condition += '(sent = true AND send_emails = true)' if search_value == 'only_sent'
                search_condition += '(sent = false AND send_emails = true)' if search_value == 'not_sent'
              end
              search_condition += 'shifts.end_date IS NULL' if search_value == 'on_going' && column_name == 'status'
              search_condition += 'shifts.end_date IS Not NULL' if search_value == 'completed' && column_name == 'status'

              if (column_name == 'status' && model_name == 'bags') || column_name == 'action_error' || column_name == 'error_type'
                search_value = search_value.downcase.gsub(' ', '_') if column_name == 'error_type'
                search_condition += "#{column_name} ILIKE '%#{search_value}%'" if %w[missing over_stuffed error].exclude?(search_value)
                if %w[missing over_stuffed error].include?(search_value) || column_name == 'action_error'
                  search_condition += "bags.status IN ('missing', 'over_stuffed')" if search_value == 'error'
                  search_condition += "bags.status IN ('missing')" if search_value == 'missing'
                  search_condition += "bags.status IN ('over_stuffed')" if search_value == 'over_stuffed'
                end
              end
            when 'announcement_type'
              search_condition += '(send_emails IS NOT NULL)' if search_value == 'display_all'
              search_condition += '(send_emails = true)' if search_value == 'in_app_only'
              search_condition += '(send_emails = false)' if search_value == 'in_app_and_email'
            when 'min_created_at', 'max_created_at', 'max_end_date', 'min_end_date', 'min_start_date', 'max_start_date', 'min_send_at', 'max_send_at'
              comparison_operator = if column_name.include?('min')
                                      ' >= '
                                    else
                                      ' <= '
                                    end
              target_value = column_name.gsub('min_', '').gsub('max_', '')
              comparison_value = convert_time(search_value)
              search_condition += "#{model_name}.#{target_value}" + "#{comparison_operator} '#{comparison_value}'"
            else
              search_condition += "#{column_name} ILIKE '%#{search_value}%'"
            end
            search_condition += ' AND ' unless search.keys.last == column_name
          end
          [search, search_condition]
        end

        def convert_time(search_value)
          Time.zone.at(search_value / 1000)
        end
      end
    end
  end
end
