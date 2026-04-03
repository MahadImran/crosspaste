require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "generates a six character code" do
    room = Room.create!

    assert_equal 6, room.code.length
    assert_match(/\A[a-z0-9]{6}\z/, room.code)
  end

  test "recognizes expired rooms" do
    assert rooms(:expired_room).expired?
    assert_not rooms(:active_room).expired?
  end

  test "rejects overly long text" do
    room = Room.new(text: "a" * 5001, last_activity_at: Time.current, code: "abc123")

    assert_not room.valid?
    assert_includes room.errors[:text], "is too long (maximum is 5000 characters)"
  end

  test "encrypts stored text at rest" do
    room = Room.create!(text: "top secret")
    stored_value = Room.connection.select_value("SELECT text FROM rooms WHERE id = #{room.id}")

    refute_equal "top secret", stored_value
    assert_equal "top secret", room.reload.text
  end

  test "reads legacy plaintext rows during the transition" do
    room = rooms(:active_room)

    assert_equal "hello from fixture", room.text
  end

  test "broadcast room frame keeps the replacement target in the markup" do
    rendered = ApplicationController.render(
      partial: "rooms/room_frame",
      locals: { room: rooms(:active_room) }
    )

    assert_includes rendered, 'id="room-shell"'
    assert_includes rendered, rooms(:active_room).text
  end

  test "broadcast deleted room frame keeps the replacement target in the markup" do
    rendered = ApplicationController.render(
      partial: "rooms/deleted_room_frame",
      locals: { code: rooms(:active_room).code }
    )

    assert_includes rendered, 'id="room-shell"'
    assert_includes rendered, "is no longer available"
  end
end
