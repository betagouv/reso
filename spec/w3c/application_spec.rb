# frozen_string_literal: true

require 'rails_helper'

describe 'application', type: :feature, js: true do
  login_user
  subject { page.body }

  describe '/besoins/:id' do
    let(:solicitation) { create :solicitation, :with_diagnosis }
    let(:need) { create :need, advisor: current_user, diagnosis: solicitation.diagnosis }
    let(:a_match) { create :match, expert: current_user.experts.first, need: need }

    before do
      solicitation
      need
      a_match
    end

    describe 'with status_quo need' do
      before do
        need.update(status: :quo)
        visit "/besoins/#{need.id}"
      end

      it { is_expected.to be_valid_html }
    end

    describe 'with status_taking_care need' do
      before do
        need.update(status: :taking_care)
        visit "/besoins/#{need.id}"
      end

      it { is_expected.to be_valid_html }
    end
  end
end
