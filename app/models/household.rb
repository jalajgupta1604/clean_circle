class Household < ApplicationRecord
  belongs_to :user
  belongs_to :route, optional: true
  has_many :pickups, dependent: :destroy

  validates :user, presence: true
  validates :address, presence: true
  validates :qr_code_token, uniqueness: true, allow_blank: true

  before_create :generate_qr_code_token

  def qr_code_svg
    qrcode = RQRCode::QRCode.new(qr_code_token)
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true,
      use_path: true
    )
  end

  def total_pickups
    pickups.completed.count
  end

  def estimated_total_waste
    pickups.completed.sum(:estimated_volume)
  end

  private

  def generate_qr_code_token
    self.qr_code_token = "HH-#{SecureRandom.hex(8).upcase}"
  end
end
