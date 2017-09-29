# frozen_string_literal: true

require 'rails_helper'

describe UseCases::GetDiagnosedNeedsWithLocalizedAssistanceExperts do
  describe 'of_diagnosis' do
    subject { described_class.of_diagnosis(diagnosis) }

    let(:facility) { create :facility, city_code: 75_001}
    let(:visit) { create :visit, facility: facility }
    let!(:territory) { create :territory }
    let!(:territory_city) { create :territory_city, territory: territory, city_code: 75_001 }

    let!(:diagnosis) { create :diagnosis, visit: visit }
    let!(:question1) { create :question }
    let!(:question2) { create :question }
    let!(:assistance1) { create :assistance, question: question1 }
    let!(:assistance2) { create :assistance, question: question2 }

    let(:expert) { create :expert, expert_territories: [expert_territory] }
    let(:expert_territory) { create :expert_territory, territory: territory }
    let!(:assistance_expert1) { create :assistance_expert, assistance: assistance1, expert: expert }

    let!(:diagnosed_need1) { create :diagnosed_need, diagnosis: diagnosis, question: question1 }
    let!(:diagnosed_need2) { create :diagnosed_need, diagnosis: diagnosis, question: question2 }

    before do
      create :diagnosed_need
      create :assistance_expert, assistance: assistance2
      # allow(AssistanceExpert).to receive(:of_city_code).and_return(assistance_expert1)
    end

    it 'gets the right diagnosed needs' do
      expect(subject).to contain_exactly(diagnosed_need1, diagnosed_need2)
    end

    it 'includes the rightly localized assistance experts' do
      returned_assistance_experts = described_class.of_diagnosis(diagnosis)
                                                   .map(&:question)
                                                   .map(&:assistances).flatten
                                                   .map(&:assistances_experts).flatten
      expect(returned_assistance_experts).to contain_exactly(assistance_expert1)
      # expect(returned_assistance_experts).to eq(expected_assistance_experts)
    end
  end
end
