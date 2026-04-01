module RoomsHelper
  def room_qr_svg(room)
    qrcode = RQRCode::QRCode.new(room_url(room.code))

    qrcode.as_svg(
      offset: 0,
      color: "currentColor",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true,
      use_path: true
    ).html_safe
  end

  def relative_expiry_label(room)
    minutes = [ ((room.expires_at - Time.current) / 60).ceil, 0 ].max
    "#{minutes}m left"
  end
end
