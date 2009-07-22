module FormHelper
  def date_select(*args)
    #args[0] == the name of the object
    #args[1] == the name of the field
    #args[2] == datepicker: true/false
    if args[2][:datepicker]
      args[2] = {:size => 10, :value => Time.now.strftime("%m/%d/%Y")}.merge(args[2])#.merge!({:size => 10, :value => Time.now.strftime("%m/%d/%Y")})
      super(*args) + "<script type='text/javascript'>$('##{args[0]}_#{args[1]}').datepicker();</script>"
    else
      super(*args)
    end
  end
  
  def timepicker(field_name)
    time_choices = (0..1440).step(@department.department_config.time_increment).map{|t| [t.min_to_am_pm, t.min_to_am_pm]}
    select(field_name.symbolize, time_choices)
    #args[0] == the name of the object
    #args[1] == the name of the field
    #args[2] == datepicker: true/false
  end
  
  def select(*args)
    if args[2] == :timepicker
      time_choices = (0..1440).step(@department.department_config.time_increment).map{|t| [t.min_to_am_pm, t.min_to_am_pm]}
      args[2] = time_choices
      #args.to_json
      super(*args)
    else
      super(*args)
    end
  end
end