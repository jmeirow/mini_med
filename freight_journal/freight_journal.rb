require './money'
require './contribution_journal_entry'


class FreightJournal

  attr_reader   :member_id, :additions, :deletions, :records,  :current_contribution_dates , :current_coverage_dates,  :added_coverage_weeks  , :removed_coverage_weeks , :uncovered_weeks_with_rates

end


 