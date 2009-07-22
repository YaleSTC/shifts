module FormHelper
  def text_field(*args)
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
  
  def datetime_picker(*args)
    #args[0] == the name of the object
    #args[1] == the name of the field
    #args[2] == datepicker: true/false
    
  end
end