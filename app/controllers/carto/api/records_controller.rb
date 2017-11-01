# encoding: UTF-8

require_relative '../../../models/carto/permission'

module Carto
  module Api
    class RecordsController < ::Api::ApplicationController
      ssl_required :show, :create, :update, :destroy

      REJECT_PARAMS = %w{ format controller action row_id requestId column_id table_id 
                      oauth_token oauth_token_secret user_token api_key user_domain }.freeze

      before_filter :set_start_time
      before_filter :load_user_table, only: [:show, :create, :update, :destroy]
      before_filter :read_privileges?, only: [:show]
      before_filter :write_privileges?, only: [:create, :update, :destroy]

      # This endpoint is not used by the editor but by users. Do not remove
      def show
        render_jsonp(@user_table.service.record(params[:id]))
      rescue => e
        CartoDB::Logger.error(message: 'Error loading record', exception: e,
                              record_id: params[:id], user_table: @user_table)
        render_jsonp({ errors: ["Record #{params[:id]} not found"] }, 404)
      end

      def create
        primary_key = @user_table.service.insert_row!(filtered_row)
        render_jsonp(@user_table.service.record(primary_key))
      rescue => e
        render_jsonp({ errors: [e.message] }, 400)
      end

      def update
        if params[:cartodb_id].present?
          begin
            resp = @user_table.service.update_row!(params[:cartodb_id], filtered_row)

            if resp > 0
              render_jsonp(@user_table.service.record(params[:cartodb_id]))
            else
              render_jsonp({ errors: ["row identified with #{params[:cartodb_id]} not found"] }, 404)
            end
          rescue => e
            CartoDB::Logger.warning(message: 'Error updating record', exception: e)
            render_jsonp({ errors: [translate_error(e.message.split("\n").first)] }, 400)
          end
        else
          render_jsonp({ errors: ["cartodb_id can't be blank"] }, 404)
        end
      end

      def destroy
        id = (params[:cartodb_id] =~ /\A\d+\z/ ? params[:cartodb_id] : params[:cartodb_id].to_s.split(','))
        schema_name = current_user.database_schema
        if current_user.id != @user_table.service.owner.id
          schema_name = @user_table.service.owner.database_schema
        end

        current_user.in_database
                    .select
                    .from(@user_table.service.name.to_sym.qualify(schema_name.to_sym))
                    .where(cartodb_id: id)
                    .delete

        head :no_content
      rescue
        render_jsonp({ errors: ["row identified with #{params[:cartodb_id]} not found"] }, 404)
      end

      protected

      def authentication_strategies
        [:user_token] + super
      end

      def filtered_row
        params.reject { |k, _| REJECT_PARAMS.include?(k) }.symbolize_keys
      end

      def load_user_table
        @user_table = Carto::Helpers::TableLocator.new.get_by_id_or_name(params[:table_id], current_user)
        raise RecordNotFound unless @user_table
      end

      # PRIVILEGIES
      # I dont like very much split the methods
      # but at the moment looks like the simplest way.
      #
      # `current_user` can respond_to `user_token` because
      # the user_token warden strategy extend user
      # with CartoDB::UserTokenDecorator
      #
      # CartoDB::UserTokenDecorator has the logic to know
      # if the `user_token` belongs to the `@user_table`
      # and if the token has read or write permissions.
      #
      # Looks like that Carto::Permission in conjuntion with Carto::Visualization
      # could be useful to solve the user_token grants in a coherent way with
      # the api_token grants but I was not able understood 
      # how `Permission` and `Visualization` really works.

      def read_privileges?
        if current_user.respond_to?(:user_token)
          head(401) unless current_user.can_read_table?(@user_table)
        else
          head(401) unless @user_table.visualization.is_viewable_by_user?(current_user)
        end
      end

      def write_privileges?
        if current_user.respond_to?(:user_token)
          head(401) unless current_user.can_write_table?(@user_table)
        else
          head(401) unless @user_table.visualization.writable_by?(current_user)
        end
      end
    end
  end
end
