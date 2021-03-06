# frozen_string_literal: true

module PageInfosHelper
  def collection_count(collection)
    collection_size = collection.total_count
    collection_name = collection.model_name.human(count: collection_size)

    if collection.total_pages < 2
      t('helpers.page_infos.collection_count_html', size: collection_size, name: collection_name)
    else
      t('helpers.page_entries_info.many_pages_html',
        total: collection_size,
        start: collection.offset_value + 1,
        end: collection.offset_value + collection.length,
        name: collection_name)
    end
  end
end
