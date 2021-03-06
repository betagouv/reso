# == Schema Information
#
# Table name: reminders_actions
#
#  id         :bigint(8)        not null, primary key
#  category   :enum             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  need_id    :bigint(8)        not null
#
# Indexes
#
#  index_reminders_actions_on_category              (category)
#  index_reminders_actions_on_need_id               (need_id)
#  index_reminders_actions_on_need_id_and_category  (need_id,category) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (need_id => needs.id)
#
class RemindersAction < ApplicationRecord
  enum category: {
    poke: 'poke', # J+7
    recall: 'recall', # J+14
    warn: 'warn', # J+21
  }, _prefix: true

  ## Associations
  #
  belongs_to :need, inverse_of: :reminders_actions, touch: true

  ## Validations
  #
  validates :need, uniqueness: { scope: [:need_id, :category] }
end
