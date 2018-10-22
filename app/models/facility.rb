# frozen_string_literal: true

class Facility < ApplicationRecord
  NUMBER_PATTERN = '[0-9]{14}'

  belongs_to :company
  belongs_to :commune
  has_many :visits
  has_many :diagnoses, through: :visits

  validates :company, :city_code, presence: true
  validates :siret, uniqueness: { allow_nil: true }

  scope :in_territory, (-> (territory) { where(city_code: territory.city_codes) })

  def to_s
    "#{company.name_short} (#{readable_locality || city_code})"
  end
end
