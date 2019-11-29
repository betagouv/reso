module Stats
  class CompaniesStats
    include BaseStats

    def main_query
      Company
        .includes(:needs).references(:needs).merge(Need.where.not(id: nil))
        .where(facilities: { diagnoses: { step: Diagnosis::LAST_STEP } })
    end

    def date_group_attribute
      'diagnoses.created_at'
    end

    def filtered(query)
      if params.territory.present?
        query = query.merge(Territory.find(params.territory).companies)
      end
      if params.institution.present?
        query = query
          .joins(diagnoses: [advisor: [antenne: :institution]])
          .where(facilities: { diagnoses: { advisor: { antennes: { institution: params.institution } } } })
      end
      query
    end

    def category_group_attribute
      :code_effectif
    end

    def category_name(category)
      Effectif::effectif(category)
    end

    def category_order_attribute
      :code_effectif
    end
  end
end
