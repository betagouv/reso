# frozen_string_literal: true

FactoryBot.define do
  factory :need do
    association :diagnosis
    association :subject
    advisor { create :user }

    factory :need_with_matches do
      before(:create) do |need, _|
        need.matches = create_list(:match, 1, need: need)
      end
    end
  end
end
