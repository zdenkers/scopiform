# frozen_string_literal: true

require 'active_support/concern'

module Scopiform
  module Filters
    extend ActiveSupport::Concern

    module ClassMethods
      def apply_filters(filters_hash, injecting = all)
        filters_hash.keys.inject(injecting) { |out, filter_name| resolve_filter(out, filter_name, filters_hash[filter_name]) }
      end

      def apply_orders(orders_hash, injecting = all)
        orders_hash.keys.inject(injecting) { |out, order_name| resolve_order(out, order_name, orders_hash[order_name]) }
      end

      private

      def resolve_filter(out, filter_name, filter_argument)
        if filter_name.to_s.casecmp('OR').zero?
          return (
            filter_argument
              .map { |or_filters_hash| apply_filters(or_filters_hash, out) }
              .inject { |chain, applied| chain.or(applied) }
          )
        end
        out.send(filter_name, filter_argument)
      end

      def resolve_order(out, order_name, order_argument)
        method_name = "order_by_#{order_name}"
        out.send(method_name, order_argument)
      end
    end
  end
end
