


class FreightJournal

  def create_contribution_journal_entry member_id, company_information_id, amount, dt, user_date 
    hash = {:member_id => member_id, :company_information_id => company_information_id,   :amount => Money.new(amount),  :week_starting => dt, :entry_type => FreightJournal.ENTRY_TYPE_CONTRIBUTION,   :user_date => user_date, :user_id => 'freight_accum' }
    ContributionJournalEntry.new(hash)
  end


  def create_coverage_journal_entry member_id, company_information_id, amount,dt , user_date
    {:member_id => member_id, :company_information_id => company_information_id, :amount => Money.new(amount),  :week_starting => dt, :entry_type => FreightJournal.ENTRY_TYPE_COVERAGE, :adjustment => false, :user_date => user_date }
  end

  def print_entry entry 
    f1 = "%5s"  % entry[:member_id]
    f2 = "%10s" % entry[:week_starting].strftime("%m/%d/%Y")
    f3 = "%10s" % entry[:amount].to_s
    f4 = "%10s" % entry[:adjustment]
    f5 = "%20s" % entry[:user_date]
    f6 = "%15s" % entry[:user_date].strftime("%m/%d/%Y")
    puts "#{f1}          #{f2}     #{f3}        #{f5}            #{f4}       #{f6}"
  end


end