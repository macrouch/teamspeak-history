module UsersHelper
  def display_time(time)
    (time + @offset).strftime("%m/%-d %H:%M")
  end
end
