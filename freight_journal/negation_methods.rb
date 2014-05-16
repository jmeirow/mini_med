class FreightJournal


  private


  def negate_coverage_when_contributions_are_reduced
    if coverage_provided_in_dollars > contributions_accumulated_dollars
      most_recent_coverage_entry = @records.select{|x| ((x[:entry_type] == FreightJournal.ENTRY_TYPE_COVERAGE) && (x[:adjustment] == false)) }.
      sort{|x,y| x[:user_date] <=> y[:user_date]}.last
      negate_coverage_entry most_recent_coverage_entry
    end
  end

  def negate_coverage_entry entry
    raise "Cannot adjust adjusted entry" if entry[:adjustment] == true
    raise "Cannot adjust contribution record with this method" if entry[:entry_type] == FreightJournal.ENTRY_TYPE_CONTRIBUTION
    adjustment = create_coverage_journal_entry(entry[:member_id],
                                              entry[:company_information_id],
                                              (entry[:amount].amount * -1),
                                              entry[:week_starting], entry[:week_starting]).merge({:adjustment => true})
    # removed_coverage_weeks << adjustment
    insert_entry adjustment
  end 

  def negate_contribution_entry entry
    raise "Cannot adjust adjusted entry" if entry[:adjustment] == true
    raise "Cannot adjust coverage record with this method" if entry[:entry_type] == FreightJournal.ENTRY_TYPE_COVERAGE
    create_contribution_journal_entry(entry[:member_id], entry[:company_information_id], (entry[:amount].amount * -1), entry[:week_starting], entry[:week_starting]).merge({:adjustment => true})
  end 


end
