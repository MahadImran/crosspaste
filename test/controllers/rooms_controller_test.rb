require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  test "renders the homepage" do
    get root_url
    assert_response :success
    assert_includes @response.body, "Move text between devices in one push."
  end

  test "creates a room and redirects to it" do
    assert_difference("Room.active.count", 1) do
      post rooms_url
    end

    room = Room.order(:created_at).last
    assert_redirected_to room_url(room.code)
  end

  test "shows an active room" do
    get room_url(rooms(:active_room).code)
    assert_response :success
    assert_includes @response.body, rooms(:active_room).code
    assert_includes @response.body, "data:image/png;base64,"
    assert_includes @response.body, "Scan the room QR to open the same shared text instantly."
  end

  test "join redirects to an active room" do
    post join_room_url, params: { code: rooms(:active_room).code.upcase }

    assert_redirected_to room_url(rooms(:active_room).code)
  end

  test "join rejects an expired room" do
    post join_room_url, params: { code: rooms(:expired_room).code }

    assert_redirected_to root_url(code: rooms(:expired_room).code)
  end

  test "updates room text" do
    patch room_url(rooms(:active_room).code), params: { room: { text: "updated text" } }

    assert_redirected_to room_url(rooms(:active_room).code)
    assert_equal "updated text", rooms(:active_room).reload.text
  end
end
