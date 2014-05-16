




def testing_dir? full_name
  return_val = false
  ["test/","spec/","vendor/bundle/","bootstrap.rb"].each{|f| return_val = true if full_name.include?(f)  }
  return_val
end
 

# preload all files.
Dir.glob('**/*.rb').reject{|file| testing_dir?(file) }.each{|file| puts file; require "./#{file}" }


FREIGHT_ACCUM_START_DATE ||= Date.new(2012,4,1)

def get_periods_to_use member_id 
  periods = []
  max_prd  = Billing::Periods::Repository.get_max_billing_period_for_member  member_id
  periods <<  max_prd.to_date ; periods << max_prd.to_date.next_month ; periods << max_prd.to_date.next_month.next_month 
  periods 
end





acc_repo = Eligibility::FreightAccumulation::Repository

# get all people who've had anything to do with freight since 4/1/2014.
# and the process member by member...
acc_repo.freight_guys_since_apr_2014.collect{|x| x[:member_id] }.each do |member_id|

  # get half-pay entries from billing data
  half_pays = acc_repo.half_pay_weeks_for_accumulation member_id                                        

  # get the member's journal data
  journal = acc_repo.get_freight_journal member_id

  # get the dates to process
  periods = get_periods_to_use member_id 
  date_range_to_look_for = periods[0].mctwf_sunday_of_week..periods[2].mctwf_last_saturday_of_month


  # from eligibility get uncovered weeks.
  uncovered_weeks = Eligibility::Coverage::UncoveredWeeks.get_for_member(member_id, date_range_to_look_for)


  next if (half_pays.length + journal.length) == 0

  company_information_id = half_pays.last[:company_information_id] if half_pays.length > 0
  company_information_id ||= journal.last[:company_information_id] if journal.length > 0


  rates_for_periods = Billing::Rates::RatesForWeeks.get_rates_for_periods(member_id ,company_information_id ,  periods)


  rate_week_ends = rates_for_periods.collect{|x| x[:week_ending] }
  uncovered_weeks_with_rates = []


 
  if uncovered_weeks.length > 0 
      

    uncovered_weeks.each do |entry|
      amount = rates_for_periods.select{|x| rate_week_ends.include?x[:week_ending]}.first[:amount]
      entry.merge!(:amount => amount)
      uncovered_weeks_with_rates << entry   
    end
  else 
    uncovered_weeks_with_rates = []
  end 



  fj = FreightJournal.new(member_id, journal,half_pays, uncovered_weeks_with_rates)

  if (fj.has_additions? || fj.has_deletions?)
    Eligibility::FreightCoverage::Repository.insert_changed_member_id member_id 
    Eligibility::FreightAccumulation::Repository.save fj
    Eligibility::FreightBenefit::Repository.save member_id, fj.current_coverage_dates
  end
end

