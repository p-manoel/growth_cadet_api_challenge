module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
        input = {
          page: index_dns_records_params[:page]&.to_i,
          included: index_dns_records_params[:included].presence&.split(',') || [],
          excluded: index_dns_records_params[:excluded].presence&.split(',') || []
        }

        ::Dns::Fetch.call(input)
          .on_success { render json: _1[:formatted_response], status: :ok }
          .on_failure { render json: { errors: _1[:errors] }, status: :unprocessable_entity }
      end

      # POST /dns_records
      def create
        input = {
          ip: create_dns_record_params[:ip].presence,
          hostnames: create_dns_record_params[:hostnames_attributes]&.map { _1[:hostname] }
        }

        ::Dns::Create.call(input)
          .on_success { render json: { id: _1[:dns].id }, status: :created }
          .on_failure(:invalid_ip_format) { render json: { errors: 'invalid ip format' }, status: :unprocessable_entity }
          .on_failure(:invalid_attributes) { render json: { errors: _1[:errors] }, status: :unprocessable_entity }
      end

      private

      def create_dns_record_params
        params.require(:dns_record
        ).permit(
          :ip,
          hostnames_attributes: [:hostname]
        )
      end

      def index_dns_records_params
        params.permit(:page, :included, :excluded)
      end
    end
  end
end
