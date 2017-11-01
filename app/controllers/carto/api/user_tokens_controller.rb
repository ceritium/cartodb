# encoding: UTF-8

require_relative '../../../models/carto/permission'
require_relative '../../../models/carto/user_table'

module Carto
  module Api
    class UserTokensController < ::Api::ApplicationController
      include PagedSearcher

      ssl_required :index, :show, :create, :destroy

      before_filter :load_user_table, only: [:index, :show, :create, :destroy]

      def index
        user_tokens = @user_table.user_tokens
        page, per_page, order = page_per_page_order_params
        user_tokens = Carto::PagedModel.paged_association(user_tokens, page, per_page, order)
        render_jsonp(user_tokens)
      end

      def show
        find_user_token
        render_jsonp(@user_token)
      end

      def create
        user_token = @user_table.user_tokens.create(writable: params.fetch(:writable, false))
        render_jsonp(user_token)
      end

      def destroy
        find_user_token
        @user_token.destroy
        render_jsonp(@user_token)
      end

      private

      def find_user_token
        @user_token = @user_table.user_tokens.find(params[:id])
      end

      def load_user_table
        @user_table = Carto::Helpers::TableLocator.new.get_by_id_or_name(params[:table_id], current_user)
        raise RecordNotFound unless @user_table
      end
    end
  end
end
