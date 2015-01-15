module ReportsHelper
  def report_kbd_shortcut
    if request.env['HTTP_USER_AGENT'].downcase.match(/mac/i)
      'Cmd+Enter to quickly add to report!'
    else
      'Ctrl+Enter to quickly add to report!'
    end
  end
end

