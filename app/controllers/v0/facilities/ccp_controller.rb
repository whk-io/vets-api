# frozen_string_literal: true

class V0::Facilities::CcpController < FacilitiesController
  before_action :validate_id, only: [:show]

  def show
    ppms = Facilities::PPMSClient.new
    result = ppms.provider_info(params[:id])
    raise Common::Exceptions::RecordNotFound, params[:id] if result.nil?
    services = ppms.provider_services(params[:id])
    caresites = ppms.provider_caresites(services[0]['CareSiteLocationAddress']) if services.present?
    result.add_caresite(caresites[0]) if caresites.present?
    render json: result, serializer: ProviderSerializer
  end

  def services
    ppms = Facilities::PPMSClient.new
    result = ppms.specialties
    render json: result
  end

  private

  def validate_id
    if /^ccp_/ =~ params[:id]
      params[:id].sub!(/^ccp_/, '')
    else
      raise Common::Exceptions::InvalidFieldValue.new('id', params[:id])
    end
  end
end