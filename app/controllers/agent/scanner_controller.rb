module Agent
  class ScannerController < BaseController
    def index; end

    def verify
      @household = Household.find_by(qr_code_token: params[:qr_code_token])

      if @household
        render json: {
          found:         true,
          household: {
            id:            @household.id,
            address:       @household.address,
            building_name: @household.building_name,
            unit_number:   @household.unit_number,
            route_id:      @household.route_id,
            customer_name: @household.user&.name
          }
        }
      else
        render json: { found: false, error: "No household found for this QR code." },
               status: :not_found
      end
    end
  end
end
