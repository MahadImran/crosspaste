class RoomsController < ApplicationController
  before_action :purge_expired_rooms
  before_action :set_room, only: [ :show, :update, :clear, :destroy ]

  def index
    @join_code = params[:code].to_s.downcase
  end

  def show
    redirect_to root_path, alert: "That room has expired or is unavailable." if @room.expired?
  end

  def create
    room = Room.create!
    redirect_to room_path(room.code), notice: "Room #{room.code} is ready."
  end

  def join
    code = normalized_code(params[:code])
    room = Room.find_by(code: code)

    if room.blank? || room.expired?
      redirect_to root_path(code: code), alert: "We couldn’t find an active room with that code."
    else
      room.touch(:last_activity_at)
      redirect_to room_path(room.code)
    end
  end

  def update
    text = room_params[:text].to_s

    if text.length > Room::MAX_TEXT_LENGTH
      redirect_to room_path(@room.code), alert: "Text must be 5000 characters or fewer."
      return
    end

    @room.push_text!(text)
    redirect_to room_path(@room.code), notice: "Synced to room."
  end

  def clear
    @room.clear_text!
    redirect_to room_path(@room.code), notice: "Shared text cleared."
  end

  def destroy
    code = @room.code
    @room.mark_deleted!
    redirect_to root_path, notice: "Room #{code} was deleted."
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to room_path(@room.code), alert: "We couldn’t delete that room right now."
  end

  private

  def set_room
    @room = Room.find_by!(code: normalized_code(params[:code]))
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "That room has expired or is unavailable."
  end

  def room_params
    params.require(:room).permit(:text)
  end

  def normalized_code(raw)
    raw.to_s.downcase.gsub(/[^a-z0-9]/, "").first(Room::CODE_LENGTH)
  end

  def purge_expired_rooms
    Room.expired.delete_all
  end
end
