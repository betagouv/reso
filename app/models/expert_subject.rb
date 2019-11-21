# == Schema Information
#
# Table name: experts_subjects
#
#  id                     :bigint(8)        not null, primary key
#  description            :string
#  expert_id              :bigint(8)
#  institution_subject_id :bigint(8)
#
# Indexes
#
#  index_experts_subjects_on_expert_id               (expert_id)
#  index_experts_subjects_on_institution_subject_id  (institution_subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (institution_subject_id => institutions_subjects.id)
#

class ExpertSubject < ApplicationRecord
  ## Associations
  #
  belongs_to :expert
  belongs_to :institution_subject

  has_many :matches, inverse_of: :expert_subject

  ## "Through" associations
  #
  has_one :subject, through: :institution_subject, inverse_of: :experts_subjects

  scope :relevant_for, -> (need) do
    experts_in_commune = need.facility.commune.all_experts
    institutions_subject = InstitutionSubject.where(subject: need.subject)
    where(institution_subject: institutions_subject)
      .where(expert: experts_in_commune)
  end

  scope :support_for, -> (diagnosis) do
    experts_in_commune = diagnosis.facility.commune.all_experts

    support.where(expert: experts_in_commune)
  end

  scope :support, -> { where(institution_subject: InstitutionSubject.support_subjects) }
end