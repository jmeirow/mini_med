  
class FreightJournal
  
  def initialize  member_id, journal_entries, half_pays, p_uncovered_periods_with_rates 
 
    @half_pays = half_pays
    @records = journal_entries
    @member_id = member_id 
    @uncovered_weeks_with_rates = p_uncovered_periods_with_rates
    compute_contribution_dates
    compute_coverage_dates

    @added_coverage_weeks = []
    @removed_coverage_weeks = []
    
    @deletions = compute_new_contribution_deletions
    @deletions.each {|x| insert_entry(x) }
    
    @additions = compute_new_contribution_additions
    @additions.each{|x| insert_entry(x) }
    
    compute_contribution_dates

    negate_coverage_when_contributions_are_reduced  
    compute_coverage_dates
 
    create_coverage_if_possible unless  @uncovered_weeks_with_rates.length == 0

    compute_coverage_dates 
  end

end 
