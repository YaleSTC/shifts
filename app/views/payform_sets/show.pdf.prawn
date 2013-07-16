for @payform in @payform_set.payforms do
  eval(Pathname(__FILE__).dirname.join("../payforms/show.pdf.prawn").read)
  pdf.start_new_page unless @payform == @payform_set.payforms.last
end
