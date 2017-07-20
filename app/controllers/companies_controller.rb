# frozen_string_literal: true

class CompaniesController < ApplicationController
  def search_by_siren
    company = UseCases::SearchCompany.with_siren params[:siren]
    @company_name = ApiEntrepriseService.company_name(company)
    location_hash = company['etablissement_siege']['commune_implantation']
    @company_location = "#{location_hash['code']} #{location_hash['value']}" if location_hash
    @company_headquarters_siret = company['entreprise']['siret_siege_social']
  end

  def search_by_name
    @firmapi_json = FirmapiService.search_companies name: params[:company][:name], county: params[:company][:county]
  end

  def show
    @visit = Visit.find params[:id]
    @facility = UseCases::SearchFacility.with_siret @visit.facility.siret
    @company = UseCases::SearchCompany.with_siret @visit.facility.siret
    @qwant_results = QwantApiService.results_for_query @visit.company_name
    render layout: 'company'
  end
end
