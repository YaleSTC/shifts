
#Name:          Nathan Griffith
#Employee ID:
#NetID:         njg24
#Department:    STC
#Week Ending:   2009-06-20
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
  
  payform_items = @payform.payform_items.map do |payform_item|
    [
      payform_item.category.name,
      payform_item.date,
      payform_item.description,
      payform_item.hours
    ]
  end

  pdf.table payform_items, :border_style => :grid,
    :row_colors => ["FFFFFF","DDDDDD"],
    :headers => ["Category","Date", "Description", "Hours"],
    :align => { 0 => :left, 1 => :left, 2 => :right}

  pdf.move_down(10)

  pdf.text "Total Hours: #{@payform.payform_items.map{|i| i.hours}.sum}", :size => 16, :style => :bold
