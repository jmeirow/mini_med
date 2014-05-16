class FreightJournal

  private

  def compute_new_contribution_additions
    additions = []
    current_weeks = current_contribution_dates

    @half_pays.each do |hp|
      matches = @records.select{|x| x[:entry_type] == FreightJournal.ENTRY_TYPE_CONTRIBUTION  && x[:week_starting] == hp[:week_starting] && current_weeks.include?(hp[:week_starting])   }
      if matches.length.even?
        additions << create_contribution_journal_entry(hp[:member_id],hp[:company_information_id], hp[:amount].amount,hp[:week_starting], hp[:week_starting] ).merge(:is_adjustment => false) 
      end 
    end
    additions
  end

  def compute_new_contribution_deletions 
    deletions = []
    current_weeks = current_contribution_dates
    @records.select {|x| x[:entry_type] == FreightJournal.ENTRY_TYPE_CONTRIBUTION  && current_weeks.include?(x[:week_starting])  }.each do |entry|
      matches = @half_pays.select{|x|  x[:week_starting] == entry[:week_starting] }
      if matches.length == 0
         deletions <<  negate_contribution_entry(entry)  
      end 
    end
    deletions
  end



end