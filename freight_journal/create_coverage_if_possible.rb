class FreightJournal


  private 

  def create_coverage_if_possible 
    skip = true
    company_information_id = 0
    uncovered_weeks_with_rates.sort{|x,y| x[:week_ending] <=> y[:week_ending]}.each do |entry|
      rate_this_week = uncovered_weeks_with_rates.first{|x| x[:week_ending] == week}[:amount]

      if  balance_on((entry[:week_ending]-6)) >= rate_this_week
        company_information_id = records.select{|x| x[:week_starting] == (entry[:week_ending]-6)}.first[:company_information_id]
        if current_coverage_dates.include?(entry[:week_ending])  == false 
          if skip
            skip = false
            next
          end
          amt = rate_this_week.amount * -1.00
          record = create_coverage_journal_entry(member_id, company_information_id, Money.new(amt) , entry[:week_ending], entry[:week_ending])
          insert_entry (record)
          skip = true
        end
      end
    end
  end 



  def insert_entry entry 
    records << entry 
  end


end
