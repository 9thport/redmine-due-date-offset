class DueDateSettingsController < AuthSourcesController
  unloadable
    
  protected
    
  def due_date_source_class
    DueDateSource
  end
    
end
