# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  login_user

  describe 'POST #search_by_siren' do
    it 'returns http success' do
      company = build :company
      siren = company.siren
      api_json = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
      allow(UseCases::SearchCompany).to receive(:with_siren).with(siren) { api_json }

      post :search_by_siren, params: { siren: siren }, format: :js

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #search_by_name' do
    subject(:request) { post :search_by_name, params: { company: search_company_params }, format: :js }

    let(:search_company_params) { { name: 'Octo', county: '75' } }

    it 'returns http success' do
      allow(FirmapiService).to receive(:search_companies)
      request
      expect(FirmapiService).to have_received(:search_companies).with(search_company_params)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    siret = '44622002200227'
    company_name = 'C H D GRAND HAINAUT'

    before do
      allow(UseCases::SearchFacility).to receive(:with_siret).with(siret)
      allow(UseCases::SearchCompany).to receive(:with_siret).with(siret)
      allow(ApiEntrepriseService).to receive(:company_name).and_return(company_name)
      allow(QwantApiService).to receive(:results_for_query).with(company_name)
    end

    it do
      get :show, params: { siret: siret }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create_diagnosis_from_siret' do
    context 'save worked' do
      it 'redirects to the created diagnosis step2 page' do
        siret = '12345678901234'
        facility = create :facility, siret: siret
        allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { facility }

        post :create_diagnosis_from_siret, format: :json, params: { siret: siret }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to step_2_diagnosis_path(Diagnosis.last)
      end
    end

    context 'saved failed' do
      it 'does not redirect' do
        allow(UseCases::SearchFacility).to receive(:with_siret_and_save)

        post :create_diagnosis_from_siret, format: :json, params: {}

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
