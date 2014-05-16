class FreightJournal

  private



  # these two methods produce distinct we
  #
  #
  #
  #
  #



  def compute_coverage_dates 
    grouped_coverage_dates =  @records.select{|x| x[:entry_type] == FreightJournal.ENTRY_TYPE_COVERAGE   }.group_by {|x| x[:week_starting]}
    @current_coverage_dates = grouped_coverage_dates.keys.select{|key| grouped_coverage_dates[key].length.odd?  }.collect{|x| x  }.sort{|x,y| x <=> y   }
  end

  def compute_contribution_dates
    grouped_contribution_entries =  @records.select{|x| x[:entry_type] == FreightJournal.ENTRY_TYPE_CONTRIBUTION    }.group_by {|x| x[:week_starting] }
    @current_contribution_dates =   grouped_contribution_entries.keys.select{|key| grouped_contribution_entries[key].length.odd?  }.collect{|x| x  }.sort{|x,y| x <=> y}
  end


end