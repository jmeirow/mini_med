require 'spec_helper'



def create_contribution_journal_entry member_id, amount, dt, date_entered 
  hash = {:member_id => member_id, :amount => Money.new(amount),  :week_starting => dt, :entry_type => FreightJournal.ENTRY_TYPE_CONTRIBUTION, :adjustment => false, :date_entered => date_entered }
  result = ContributionJournalEntry.new(hash)
end

def create_coverage_journal_entry member_id,amount,dt , date_entered
  {:member_id => member_id, :amount => Money.new(amount),  :week_starting => dt, :entry_type => FreightJournal.ENTRY_TYPE_COVERAGE, :adjustment => false, :date_entered => date_entered }
end

def create_half_pay_entry member_id, amount , dt, date_entered
  {:member_id => member_id,   :week_starting => dt , :amount => Money.new(amount) , :date_entered => date_entered   }
end

def make_hash id, dt , amt, date_entered
  {:member_id => id, :week_starting => dt, :amount => amt, :date_entered => date_entered}
end

def create_half_pays_from_journal journal_entries
  deleted_entries = journal_entries.select{|x| (x[:adjustment] == true && x[:entry_type] == FreightJournal.ENTRY_TYPE_CONTRIBUTION)}.collect{|x| x[:week_starting]}
  interim_results = journal_entries.select{|x| (x[:adjustment] == false && x[:entry_type] == FreightJournal.ENTRY_TYPE_CONTRIBUTION) }.collect{|x| make_hash(x[:member_id], x[:week_starting], x[:amount], x[:date_entered]    )  }
  deleted_entries.each{|x|  interim_results.delete(interim_results.find{|x| x[:week_starting] == x})}
  interim_results
end


def not_covered_1 

  rates = {}
  dt = Date.new(2014,4,1).mctwf_sunday_of_week
  (1..100).each do |i|
    rates[dt]
    if i < 50 
      rates[dt] = Money.new(300.00)
    else
      rates[dt] = Money.new(325.00)
    end
    dt += 7
  end
  rates
end

def create_contribution_journal_entries journal, mbr_id, amt, dt, number_of_weeks
  (1..number_of_weeks).each do |x|
    journal <<  create_contribution_journal_entry(mbr_id, amt, dt, dt) ; dt += 7  
  end 
end
def create_half_pays half_pays, mbr_id, amt, dt, number_of_weeks
   (1..number_of_weeks).each do |x|
    half_pays <<  create_half_pay_entry(mbr_id, amt, dt, dt) ; dt += 7  
  end 
end


# HIGH LEVEL
# update journal
# get freight guys with balances
# check eligibility for first week of non-coverage 
# given a member, an amount and a date, if there is a balance >= amount passed, create a journal for coverage using the amount
# => and date passed, then return true.  Else, return false




describe FreightJournal do 

  it "should be able to identify new journal entries from half pay contribution data" do 
    half_pays = []
    journal_entries = []
    dt = Date.today.mctwf_sunday_of_week
    create_half_pays(half_pays, 1000,34.00,dt,10)

    dt = Date.today.mctwf_sunday_of_week
    create_contribution_journal_entries(journal_entries, 1000,34.00,dt,10)

    fj = FreightJournal.new(1000,journal_entries,half_pays, not_covered_1)

    #fj.to_s
  end


  it "should return an map that is a half_pay contribution object" do 
    journal_entries = []
    half_pays = [create_half_pay_entry( 1000, 34.00, Date.today.mctwf_sunday_of_week, Date.today.mctwf_sunday_of_week)   ]
    fj = FreightJournal.new(journal_entries,half_pays,{})
    fj.additions.first[:member_id].should eq(1000)
  end




  it "should recognize half pays that are already in the journal" do 
    half_pays = [create_half_pay_entry( 1000,34.00, Date.today.mctwf_sunday_of_week, Date.today.mctwf_sunday_of_week)   ]
    journal_entries = [create_contribution_journal_entry(1000, 34.00,  Date.today.mctwf_sunday_of_week, Date.today.mctwf_sunday_of_week) ]
    fj = FreightJournal.new(journal_entries,half_pays,{})
    fj.additions.length.should eq(0)
  end






  it "should recognize half pays that are already in the journal and return any that are not" do 

    #arrange

    half_pays = []
    half_pays << create_half_pay_entry( 1000, 34.00, Date.today.mctwf_sunday_of_week  , Date.today.mctwf_sunday_of_week)  
    half_pays << create_half_pay_entry( 1000, 34.00, Date.today.mctwf_sunday_of_week+7, Date.today.mctwf_sunday_of_week+7 )  
    journal_entries = [ create_contribution_journal_entry(1000, 34.00,  Date.today.mctwf_sunday_of_week, Date.today.mctwf_sunday_of_week) ]


    #assert

    fj = FreightJournal.new(journal_entries,half_pays,{})

 

    fj.additions.length.should eq(1)

    half_pays = []
    half_pays << create_half_pay_entry( 1000, 34.00, Date.today.mctwf_sunday_of_week  ,Date.today.mctwf_sunday_of_week)  
    half_pays << create_half_pay_entry( 1000, 34.00, Date.today.mctwf_sunday_of_week+7, Date.today.mctwf_sunday_of_week+7 )  
    journal_entries = [ create_contribution_journal_entry(1000, 34.00,  Date.today.mctwf_sunday_of_week,Date.today.mctwf_sunday_of_week) ]


    fj = FreightJournal.new(journal_entries,half_pays,{})
    fj.additions.first[:week_starting].should eq( (Date.today + 7 ).mctwf_sunday_of_week)

  end

  




  
 
  # # BALANCES

  it 'should know be able to compute a balance from all entries' do 

    #setup

    journal = []
    half_pays = []
    dt = Date.today.mctwf_sunday_of_week+7

    create_contribution_journal_entries(journal, 1000, 34.00,dt,2 )
    dt = Date.today.mctwf_sunday_of_week+7
    
    create_half_pays(half_pays, 1000,34.00,dt,2)

    fj = FreightJournal.new(journal,half_pays, {})


    #test 

     fj.balance.to_s.should eq(Money.new(68.00).to_s)

  end






  it 'should be able to compute a balance from all entries, including offsetting entries' do 

    #setup

    dt = Date.today.mctwf_sunday_of_week
    journal = []
    half_pays = []
    create_contribution_journal_entries(journal, 1000,34.00,dt,3)
    dt = Date.today.mctwf_sunday_of_week
    create_half_pays(half_pays, 1000,34.00,dt,3)

    fj = FreightJournal.new(journal, half_pays,{})

    #test

    expect(fj.balance).to eq(Money.new(102.00))
  end







  # # NEGATED DATES


  it 'should recognize negated entries ' do 


    journal = []
    half_pays = []

    dt = Date.today.mctwf_sunday_of_week
    create_half_pays(half_pays, 1000,34.00,dt,2)

    dt = Date.today.mctwf_sunday_of_week
    create_contribution_journal_entries(journal, 1000,34.00,dt,3)

    fj = FreightJournal.new(journal, half_pays,{})

    fj.current_contribution_dates.include?(Date.today.mctwf_sunday_of_week+14).should eq(false)
  end 







  it 'should provide a method that is called to determine if there is enough balance to create coverage ' do 

    #setup


    journal = []
    half_pays = []

    dt = Date.new(2014,4,1).mctwf_sunday_of_week
    create_half_pays(half_pays, 1000,34.00,dt,9)

    dt = Date.new(2014,4,1).mctwf_sunday_of_week
    create_contribution_journal_entries(journal, 1000,34.00,dt,9)

    fj = FreightJournal.new(journal, half_pays,not_covered_1)

    #fj.to_s


    #test
      
    fj.balance.to_s.should eq(Money.new(6.00).to_s)
    #fj.to_s

  end


 

  it 'should provide a method that is called to determine if there is enough balance to create coverage ' do 

    #setup


    journal = []
    half_pays = []

    dt = Date.new(2014,4,1).mctwf_sunday_of_week
    create_half_pays(half_pays, 1000,34.00,dt,9)

    dt = Date.new(2014,4,1).mctwf_sunday_of_week
    create_contribution_journal_entries(journal, 1000,34.00,dt,9)

    create_half_pays(half_pays, 1000,34.00,dt,9)

    fj = FreightJournal.new(journal, half_pays,not_covered_1)

    #fj.to_s


    journal = fj.records.clone
    half_pays = []
    dt = Date.new(2014,4,1).mctwf_sunday_of_week
    create_half_pays(half_pays, 1000,34.00,dt,21)
    fj2 = FreightJournal.new(journal,half_pays,not_covered_1)
    
    fj2.balance.to_s.should eq(Money.new(114.00).to_s)    

    
  end


  it 'should return a correct balance after deducting for coverage ' do 

    #setup

    journal = []
    half_pays = []

    dt = Date.today.mctwf_sunday_of_week
    create_half_pays(half_pays, 1000,34.00,dt,9)

    dt = Date.today.mctwf_sunday_of_week
    create_contribution_journal_entries(journal, 1000,34.00,dt,9)

    fj = FreightJournal.new(journal, half_pays, {})
    fj.balance.to_s.should eq(Money.new(306.00).to_s)
    # fj.to_s
  end

  it 'should return a correct balance after deducting for coverage ' do 

    #setup

    journal = []
    half_pays = []

    dt = Date.today.mctwf_sunday_of_week
    create_half_pays(half_pays, 1000,34.00,dt,9)

    dt = Date.today.mctwf_sunday_of_week
    create_contribution_journal_entries(journal, 1000,34.00,dt,9)

    fj = FreightJournal.new(journal, half_pays, not_covered_1)
    fj.balance.to_s.should eq(Money.new(6.00).to_s)
    # fj.to_s


  end







  it 'should negate a coverage entry if a contribution entry is negated that takes new balance below coverage amount' do 

    #setup

    journal = []
    half_pays = []

    dt = Date.today.mctwf_sunday_of_week
    create_half_pays(half_pays, 1000,34.00,dt,9)

    dt = Date.today.mctwf_sunday_of_week
    create_contribution_journal_entries(journal, 1000,34.00,dt,9)

    fj = FreightJournal.new(journal, half_pays, not_covered_1)
    
      fj.to_s

    
    # # test
    
    half_pays =[]
    journal.each_with_index do |entry,idx|
      if idx < (journal.length - 3) # first 8 entries
        half_pays << create_half_pay_entry(entry[:member_id], entry[:amount].amount ,   entry[:week_starting],  entry[:week_starting] )
      end
    end


    fj2 = FreightJournal.new(fj.records,half_pays , not_covered_1   )

    #test
     fj2.to_s
      fj2.balance.to_s.should eq(Money.new(238.00).to_s)   # =>  8 * 34.00 

    puts "added coverage weeks= #{fj2.added_coverage_weeks.length}"

    fj2.current_coverage_dates.length.should eq(0)
    fj2.has_deletions?.should be(true)
  end

end