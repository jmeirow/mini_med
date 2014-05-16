require 'map'

class ContributionJournalEntry < Map

  attr_reader :member_id, :company_information_id, :amount, :week_starting, :is_adjustment, :entry_type, :user_date, :user_id

end

