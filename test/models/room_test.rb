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
end
