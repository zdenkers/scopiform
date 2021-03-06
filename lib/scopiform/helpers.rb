# frozen_string_literal: true

require 'active_support/concern'

module Scopiform
  module Helpers
    extend ActiveSupport::Concern

    STRING_TYPES = %i[string text].freeze
    NUMBER_TYPES = %i[integer float decimal].freeze
    DATE_TYPES = %i[date time datetime timestamp].freeze

    module ClassMethods
      def attribute_aliases
        alias_hash = super

        key = primary_key.to_s
        alias_hash = alias_hash.merge('id' => key) if key != 'id'

        alias_hash
      end

      def attribute_aliases_inverted
        attribute_aliases.each_with_object({}) { |(k, v), o| (o[v] ||= []) << k }
      end

      def resolve_alias(name)
        name_str = name.to_s
        return attribute_aliases[name_str] if attribute_aliases[name_str].present?

        name_str
      end

      def aliases_for(name)
        attribute_aliases_inverted[name.to_s] || []
      end

      def column(name)
        name = resolve_alias(name)
        columns_hash[name.to_s]
      end

      def association(name)
        name = resolve_alias(name)
        reflect_on_association(name)
      end
    end
  end
end
