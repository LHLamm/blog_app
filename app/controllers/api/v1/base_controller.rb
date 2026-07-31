module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_with_bearer_token!

      private

      def authenticate_with_bearer_token!
        provided_token = bearer_token_from_header
        unless provided_token.present? && valid_token?(provided_token)
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def bearer_token_from_header
        header = request.headers["Authorization"]
        return nil unless header
        scheme, token = header.split(" ", 2)
        return nil unless scheme&.downcase == "bearer"
        token
      end

      def valid_token?(provided_token)
        expected_token = expected_bearer_token
        return false if expected_token.blank?

        ActiveSupport::SecurityUtils.secure_compare(provided_token, expected_token)
      end

      def expected_bearer_token
        Rails.application.credentials.dig(:api, :bearer_token) || ENV["API_BEARER_TOKEN"]
      end
    end
  end
end
