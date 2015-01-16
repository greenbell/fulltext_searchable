module FulltextSearchable
  class Engine < Rails::Engine
    config.class_eval do
      def async=(value)
        ActiveSupport::Deprecation.warn 'FulltextSearchable::Engine.config.async no longer exists and has no effect.'
      end
    end
  end
end
