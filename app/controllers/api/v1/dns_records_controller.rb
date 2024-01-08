module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
        # TODO: Implement this action
      end

      # POST /dns_records
      def create
        input = {
          ip: dns_record_params[:ip].presence,
          hostnames: dns_record_params[:hostnames_attributes]&.map { _1[:hostname] }
        }

        ::Dns::Create.call(input)
          .on_success { render json: { id: _1[:dns].id }, status: :created }
          .on_failure(:invalid_ip_format) { render json: { errors: 'invalid ip format' }, status: :unprocessable_entity }
          .on_failure(:invalid_attributes) { render json: { errors: _1[:errors] }, status: :unprocessable_entity }
      end

      private

      def dns_record_params
        params.require(:dns_record).permit(
          :ip,
          hostnames_attributes: [:hostname]
        )
      end
    end
  end
end
