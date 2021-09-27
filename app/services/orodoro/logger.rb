class Orodoro::Logger
  
  def initialize(log_params = {})
    @log_params = log_params
  end

  def log!
    @light_api_log = LightApiLog.new(@log_params)
    @light_api_log.contents = contents unless @light_api_log.is_failed?
    @light_api_log.save
  end

  private

  def contents    
    "#{klass_name} # #{object_number} was #{event_in_past} on Orodoro"
  end

  def object_number
    @object_number ||= @log_params[:light_api_entity_id]
  end

  def klass_name
    @klass_name ||= @log_params[:entity_type]
  end

  def event_in_past
    case @log_params[:event]
    when LightApiLog::CREATE_EVENT
      'created'
    when LightApiLog::DESTROY_EVENT
      'destroyed'
    end
  end

end
