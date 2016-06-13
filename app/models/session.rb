# frozen_string_literal: true
class Session < ActiveRecord::SessionStore::Session
  include Flippable

  belongs_to :user

  before_save :copy_to_columns

  def copy_to_columns
    self.user_id = data['user_id']
  end
end
