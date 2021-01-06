module Stats::Public
  class ExchangeWithExpertStats
    include ::Stats::BaseStats

    def main_query
      Need.diagnosis_completed
    end

    def filtered(query)
      if territory.present?
        query.merge! territory.needs
      end
      if institution.present?
        query.merge! institution.received_needs
      end
      if @start_date.present?
        query.where!(needs: { created_at: @start_date..@end_date })
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)

      @needs_with_exchange ||= needs_with_exchange(query).values
      @needs_without_exchange ||= needs_without_exchange(query).values

      as_series(@needs_with_exchange, @needs_without_exchange)
    end

    def needs_with_exchange(query)
      query
        .with_exchange
        .group_by_month(date_group_attribute)
        .count
    end

    def needs_without_exchange(query)
      query
        .without_exchange
        .group_by_month(date_group_attribute)
        .count
    end

    def subtitle
      I18n.t('stats.series.exchange_with_expert.subtitle_html')
    end

    def count
      build_series
      percentage_two_numbers(@needs_with_exchange, @needs_without_exchange)
    end

    def format
      '{series.name} : <b>{point.percentage:.0f}%</b> (Total : {point.stackTotal})'
    end

    private

    def as_series(needs_with_exchange, needs_without_exchange)
      [
        {
          name: I18n.t('stats.series.exchange_with_expert.without_exchange'),
          data: needs_without_exchange
        },
        {
          name: I18n.t('stats.series.exchange_with_expert.with_exchange'),
          data: needs_with_exchange
        }
      ]
    end
  end
end