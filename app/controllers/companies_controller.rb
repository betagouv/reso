# frozen_string_literal: true

class CompaniesController < ApplicationController
  def search
    @query = search_query
    if @query.present?
      siret = siret(@query)
      if siret.present? && Facility::siret_is_valid(siret)
        redirect_to company_path(siret, query: @query)
      else
        search_results
      end
    end
  end

  def show
    siret = params[:siret]
    query = params[:query]
    begin
      @facility = UseCases::SearchFacility.with_siret siret
      @company = UseCases::SearchCompany.with_siret siret
    rescue ApiEntreprise::ApiEntrepriseError => error
      redirect_back fallback_location: { action: :search }, alert: error
      return
    end
    existing_facility = Facility.find_by(siret: siret)
    if existing_facility.present?
      @diagnoses = Facility.find_by(siret: siret).diagnoses
        .completed
        .distinct
        .left_outer_joins(:matches,
          diagnosed_needs: :matches)
        .includes(:matches,
          diagnosed_needs: :matches,
          visit: :advisor)
    else
      @diagnoses = Diagnosis.none
    end
    save_search(query, @company.name)
  end

  def create_diagnosis_from_siret
    facility = UseCases::SearchFacility.with_siret_and_save(params[:siret])

    if facility
      visit = Visit.new(advisor: current_user, facility: facility)
      diagnosis = Diagnosis.new(visit: visit, step: '2')
    end

    if diagnosis&.save
      redirect_to besoins_diagnosis_path(diagnosis)
    else
      render body: nil, status: :bad_request
    end
  end

  private

  def search_results
    response = SireneApi::SireneSearch.search(@query)
    if response.success?
      @etablissements = response.etablissements
      @suggestions = response.suggestions
    else
      flash.now.alert = response.error_message || I18n.t('companies.search.generic_error')
    end
    save_search(@query)
  end

  def search_query
    query = params['query']
    query.present? ? query.strip : nil
  end

  def siret(query)
    maybe_siret = query.gsub(/\s+/, '')
    maybe_siret if maybe_siret.match?(/\d{14}/)
  end

  def save_search(query, label = nil)
    Search.create user: current_user, query: query, label: label
  end
end
