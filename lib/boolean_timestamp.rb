require "boolean_timestamp/version"

require "active_record"

module BooleanTimestamp
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def boolean_timestamp(method_name, strict: true)
      method_name = String(method_name)
      column_name = "#{method_name}_at"
      fully_qualified_column_name = "#{table_name}.#{column_name}"

      define_boolean_timestamp_scopes(method_name, fully_qualified_column_name, strict: strict)
      define_boolean_timestamp_accessors(method_name, column_name, strict: strict)
    end

    private

    def define_boolean_timestamp_scopes(method_name, fully_qualified_column_name, strict:)
      if strict
        define_boolean_timestamp_strict_scopes(method_name, fully_qualified_column_name)
      else
        define_boolean_timestamp_loose_scopes(method_name, fully_qualified_column_name)
      end
    end

    def define_boolean_timestamp_strict_scopes(method_name, fully_qualified_column_name)
      scope(method_name, -> { where("#{fully_qualified_column_name} <= ?", Time.current) })

      scope(
        "not_#{method_name}",
        lambda do
          where(
            "#{fully_qualified_column_name} IS NULL OR #{fully_qualified_column_name} > ?",
            Time.current
          )
        end
      )
    end

    def define_boolean_timestamp_loose_scopes(method_name, fully_qualified_column_name)
      scope(method_name, -> { where("#{fully_qualified_column_name} IS NOT NULL") })
      scope("not_#{method_name}", -> { where("#{fully_qualified_column_name} IS NULL") })
    end

    def define_boolean_timestamp_accessors(method_name, column_name, strict:)
      if strict
        define_boolean_timestamp_strict_reader(method_name, column_name)
      else
        define_boolean_timestamp_loose_reader(method_name, column_name)
      end

      alias_method("#{method_name}?", method_name)

      define_method("#{method_name}=") do |value|
        if ActiveModel::Type::Boolean::FALSE_VALUES.include?(value)
          public_send("#{column_name}=", nil)
        elsif !public_send(method_name)
          public_send("#{column_name}=", Time.current)
        end
      end
    end

    def define_boolean_timestamp_strict_reader(method_name, column_name)
      define_method(method_name) do
        public_send(column_name).present? && !public_send(column_name).future?
      end
    end

    def define_boolean_timestamp_loose_reader(method_name, column_name)
      define_method(method_name) do
        public_send(column_name).present?
      end
    end
  end
end
