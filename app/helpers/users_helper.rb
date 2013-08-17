module UsersHelper
  def display_time(time)
    (time + @offset).strftime("%-d %b %H:%M")
  end
end
