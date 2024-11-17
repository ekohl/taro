# Abstract base class for Page types (paginated ActiveRecord data).
# Unlike other types, this one should not be manually inherited from,
# but is used indirectly via `page_of: SomeType`.
#
# The gem rails_cursor_pagination must be installed to use this.
#
class Taro::Types::ObjectTypes::PageType < Taro::Types::BaseType
  extend Taro::Types::Shared::ItemType

  def coerce_input
    input_error 'PageTypes cannot be used as input types'
  end

  def coerce_response(after:, items_key: nil, limit: 20, order_by: nil, order: nil)
    list = RailsCursorPagination::Paginator.new(
      object, limit:, order_by:, order:, after:
    ).fetch
    coerce_paginated_list(list, items_key:)
  end

  def coerce_paginated_list(list, items_key:)
    item_type = self.class.item_type
    items = list[:page].map do |item|
      item_type.new(item[:data]).coerce_response
    end
    items_key ||= self.class.items_key

    {
      items_key.to_sym => items,
      page_info: Taro::Types::ObjectTypes::PageInfoType.new(list[:page_info]).coerce_response,
    }
  end

  # support overrides, e.g. based on item_type
  def self.items_key
    :page
  end

  define_derived_type :page
end
