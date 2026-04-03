class Room < ApplicationRecord
  CODE_ALPHABET = "abcdefghjkmnpqrstuvwxyz23456789".freeze
  CODE_LENGTH = 6
  MAX_TEXT_LENGTH = 5000
  EXPIRY_WINDOW = 1.hour

  encrypts :text, support_unencrypted_data: true, compress: false

  before_validation :assign_code, on: :create
  before_validation :set_initial_activity, on: :create

  validates :code,
    presence: true,
    uniqueness: true,
    format: { with: /\A[a-z0-9]{6}\z/, message: "must be 6 lowercase letters or digits" }
  validates :text, length: { maximum: MAX_TEXT_LENGTH }
  validates :last_activity_at, presence: true

  scope :active, -> { where(deleted_at: nil).where("last_activity_at >= ?", EXPIRY_WINDOW.ago) }
  scope :expired, -> { where("last_activity_at < ? OR deleted_at IS NOT NULL", EXPIRY_WINDOW.ago) }

  after_update_commit :broadcast_room_shell
  after_destroy_commit :broadcast_deleted_room_shell

  def self.generate_code
    alphabet = CODE_ALPHABET.chars
    Array.new(CODE_LENGTH) { alphabet.sample }.join
  end

  def expired?
    deleted_at.present? || last_activity_at < EXPIRY_WINDOW.ago
  end

  def expires_at
    last_activity_at + EXPIRY_WINDOW
  end

  def push_text!(value)
    update!(text: value.to_s, last_activity_at: Time.current)
  end

  def clear_text!
    update!(text: "", last_activity_at: Time.current)
  end

  def mark_deleted!
    update_column(:deleted_at, Time.current)
    destroy!
  end

  private

  def assign_code
    return if code.present?

    self.code = loop do
      candidate = self.class.generate_code
      break candidate unless self.class.exists?(code: candidate)
    end
  end

  def set_initial_activity
    self.last_activity_at ||= Time.current
  end

  def broadcast_room_shell
    broadcast_replace_to(
      self,
      target: "room-shell",
      partial: "rooms/room_frame",
      locals: { room: self }
    )
  end

  def broadcast_deleted_room_shell
    broadcast_replace_to(
      self,
      target: "room-shell",
      partial: "rooms/deleted_room_frame",
      locals: { code: code }
    )
  end
end
