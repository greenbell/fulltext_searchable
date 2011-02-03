module FulltextSearchable
  class Engine < Rails::Engine

    # if set to true, updates are processed asynchronously(in another thread)
    config.async = false
  end
end
