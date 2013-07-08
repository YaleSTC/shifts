// Ctrl+Enter adds to the report
$('#item').keydown(function (e) {
  if (e.keyCode === 13 && e.ctrlKey) {
    $('#report_item_submit').click();
    e.preventDefault;
  }
});