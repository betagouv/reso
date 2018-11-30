# frozen_string_literal: true

class User < ApplicationRecord
  ## Constants
  #
  WHITELISTED_DOMAINS = %w[beta.gouv.fr direccte.gouv.fr pole-emploi.fr pole-emploi.net cma-hautsdefrance.fr].freeze

  ##
  #
  include PersonConcern
  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :rememberable, :trackable, :async

  ## Associations
  #
  belongs_to :antenne, counter_cache: true, inverse_of: :advisors

  has_and_belongs_to_many :experts, inverse_of: :users

  has_many :relays
  has_many :relay_territories, through: :relays, source: :territory, inverse_of: :relay_users # TODO should be named :relay_territories when we get rid of the Relay model and use a HABTM
  has_many :relay_matches, through: :relays, source: :matches, inverse_of: :relay_user

  has_many :visits, foreign_key: 'advisor_id', inverse_of: :advisor
  has_many :sent_diagnoses, through: :visits, source: :diagnosis, inverse_of: :advisor # TODO Should be a direct association when we merge the Visit and Diagnosis models

  has_many :searches, dependent: :destroy, inverse_of: :user

  ## Validations
  #
  validates :full_name, :email, :phone_number, presence: true

  validates :email,
    uniqueness: true,
    format: { with: Devise.email_regexp },
    allow_blank: true,
    if: :will_save_change_to_email?

  validates :password, length: { within: Devise.password_length }, allow_blank: true
  validates :password, presence: true, confirmation: true, if: :password_required?

  before_create :auto_approve_if_whitelisted_domain

  ## “Through” Associations
  #
  # :antenne
  has_one :antenne_institution, through: :antenne, source: :institution, inverse_of: :advisors # TODO Should be named :institution when we remove the :institution text field.
  has_many :antenne_communes, through: :antenne, source: :communes, inverse_of: :advisors
  has_many :antenne_territories, through: :antenne, source: :territories, inverse_of: :advisors

  # :sent_diagnoses
  has_many :sent_diagnosed_needs, through: :sent_diagnoses, source: :diagnosed_needs, inverse_of: :advisor
  has_many :sent_matches, through: :sent_diagnoses, source: :matches, inverse_of: :advisor

  ## Scopes
  #
  scope :with_contact_page_order, (-> { where.not(contact_page_order: nil).order(:contact_page_order) })
  scope :contact_relays, (lambda do
    not_admin
      .joins(:relays)
      .includes(relays: :territory)
      .order('territories.name', :contact_page_order, :full_name)
      .distinct
  end)
  scope :admin, (-> { where(is_admin: true) })
  scope :not_admin, (-> { where(is_admin: false) })
  scope :approved, -> { where(is_approved: true) }
  scope :not_approved, -> { where(is_approved: false) }
  scope :email_not_confirmed, -> { where(confirmed_at: nil) }

  scope :ordered_by_institution, -> do
    joins(:antenne, :antenne_institution)
      .select('users.*', 'antennes.name', 'institutions.name')
      .order('institutions.name', 'antennes.name', :full_name)
  end

  scope :active_searchers, (lambda do |date|
    joins(:searches)
        .merge(Search.where(created_at: date))
        .distinct
  end)

  scope :active_diagnosers, (lambda do |date, minimum_step|
    joins(visits: :diagnosis)
        .merge(Diagnosis.only_active
                   .where(created_at: date)
                   .after_step(minimum_step))
        .distinct
  end)

  scope :active_matchers, (lambda do |date|
    joins(visits: [diagnosis: [diagnosed_needs: :matches]])
        .merge(Diagnosis.only_active
               .where(created_at: date))
        .distinct
  end)

  scope :active_answered, (lambda do |date, status|
    joins(visits: [diagnosis: [diagnosed_needs: :matches]])
        .merge(Match
                   .where(taken_care_of_at: date)
                   .with_status(status))
        .distinct
  end)

  scope :without_antenne, -> do
    where(antenne_id: nil)
  end

  ##
  #
  def active_for_authentication?
    super && is_approved?
  end

  ## Administration helpers
  #
  def auto_approve_if_whitelisted_domain
    email_domain = email.split("@").last
    if email_domain.in?(WHITELISTED_DOMAINS)
      self.is_approved = true
    end
  end

  def corresponding_experts
    Expert.where(email: self.email)
  end

  def autolink_experts!
    if self.experts.empty?
      corresponding = self.corresponding_experts
      if corresponding.present?
        self.experts = corresponding
        self.save!
      end
    end
  end

  def corresponding_antenne
    if self.experts.present?
      return self.experts.first.antenne
    end

    antennes = Antenne.where('name ILIKE ?', "%#{self.institution}%")
    if antennes.one?
      return antennes.first
    end

    antennes = Antenne.joins(:experts)
      .distinct
      .where('experts.email ILIKE ?', "%#{self.email.split('@').last}")
    if antennes.one?
      return antennes.first
    end
  end

  def autolink_antenne!
    if self.antenne.nil?
      corresponding = self.corresponding_antenne
      if corresponding.present?
        self.antenne = corresponding
        self.save!
      end
    end
  end

  ##
  #
  def is_oneself?
    self.experts.size == 1 && self.experts.first.users == [self]
  end

  def full_name_with_role
    if antenne.present?
      "#{full_name} (#{role}, #{antenne.name})"
    else
      "#{full_name} (#{role}, #{institution})"
    end
  end

  protected

  # Inspired by Devise validatable module
  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
