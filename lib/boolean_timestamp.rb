require "boolean_timestamp/version"

module BooleanTimestamp
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def boolean_timestamp(method_name)
      method_name = String(method_name)
      column_name = "#{method_name}_at"
      fully_qualified_column_name = "#{table_name}.#{column_name}"

      unless column_names.include?(column_name)
        raise(
          ArgumentError,
          "Can't build methods from unknown column '#{fully_qualified_column_name}'",
        )
      end

      define_singleton_method(method_name) do
        where("#{fully_qualified_column_name} <= ?", Time.current)
      end

      define_singleton_method("not_#{method_name}") do
        where(
          "#{fully_qualified_column_name} IS NULL OR #{fully_qualified_column_name} > ?",
          Time.current,
        )
      end

      define_method method_name do
        public_send(column_name).present? && !public_send(column_name).future?
      end

      alias_method "#{method_name}?", method_name

      define_method "#{method_name}=" do |value|
        if ActiveModel::Type::Boolean::FALSE_VALUES.include?(value)
          public_send("#{column_name}=", nil)
        elsif !public_send(method_name)
          public_send("#{column_name}=", Time.current)
        end
      end
    end
  end
end
