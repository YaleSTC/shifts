#Network Troubleshooting
#2009-06-18       aggghhh                                                                                      10.0
#2009-06-18       mffffff                                                                                       2.0
#                                                                                              Category Hours: 12.0
#Work-Related E-mail
#2009-06-18       emaillllz                                                                                     7.0
#                                                                                               Category Hours: 7.0
#                                        TOTAL HOURS: 19.0
#                  This payform was approved by Nathan Griffith at 03:53PM on Thu Jun 18, 2009



  pdf.font "Helvetica"
  
  pdf.text "Name: #{@payform.user.name}"
  pdf.text "Login: #{@payform.user.login}"
  pdf.text "Department: #{@payform.department.name}"
  pdf.text "Week Ending: #{@payform.date.strftime(date_format)}"
  
  for category in current_department.categories do
    payform_items = category.payform_items & @payform.payform_items
    unless payform_items.empty?
      table_items = @payform.payform_items.map do |table_item|
        [table_item.date, table_item.description, table_item.hours]
      end
      pdf.table table_items, :border_style => :grid,
                             :row_colors => ["FFFFFF","DDDDDD"],
                             :headers => [category.name,"",payform_items.map{|i| i.hours}.sum],
                             :align => { 0 => :left, 1 => :left, 2 => :right}
    end
  end
  
  pdf.move_down(10)

  pdf.text "Total Hours: #{@payform.payform_items.map{|i| i.hours}.sum}", :size => 16, :style => :bold
