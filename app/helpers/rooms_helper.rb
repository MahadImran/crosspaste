module RoomsHelper
  def room_qr_image(room)
    qrcode = RQRCode::QRCode.new(room_url(room.code))
    png = qrcode.as_png(
      size: 300,
      border_modules: 4,
      color: "black",
      fill: "white"
    )

    image_tag(
      "data:image/png;base64,#{Base64.strict_encode64(png.to_blob)}",
      alt: "QR code for room #{room.code}",
      width: 300,
      height: 300
    )
  end

  def relative_expiry_label(room)
    minutes = [ ((room.expires_at - Time.current) / 60).ceil, 0 ].max
    "#{minutes}m left"
  end
end
