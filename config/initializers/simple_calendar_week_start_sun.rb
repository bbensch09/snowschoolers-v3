module SimpleCalendar
  class MonthCalendar < SimpleCalendar::Calendar
    private
      def date_range
        week_start_day = :sunday #options.fetch(:week_start_day, :sunday)
        beginning_of_week = start_date.beginning_of_month.beginning_of_week(week_start_day)
        end_of_week  = start_date.end_of_month.end_of_week(week_start_day)
        (beginning_of_week..end_of_week).to_a
      end
  end
end