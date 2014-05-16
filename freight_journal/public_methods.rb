

class FreightJournal

  def balance
    records.inject(Money.new(0.00)){ |sum,x | sum = (sum + x[:amount])}
  end

  def balance_on date 
    result = records.select{|x| x[:user_date] <= date}.inject(Money.new(0.00)){ |sum,x | sum = (sum + x[:amount])}
    result
  end

  def to_s
    puts "\n"
    puts "member id      week starting dt   amount                entry type         adjusting entry          date entered"
    puts "=" * 112
    @records.sort{|x,y| x[:user_date] <=> y[:user_date]}.each {|x| print_entry x}
  end

  def self.ENTRY_TYPE_CONTRIBUTION
    'contribution'
  end 

  def self.ENTRY_TYPE_COVERAGE
    'coverage'
  end
  def has_additions?
    additions.length > 0
  end
  def has_deletions?
    deletions.length > 0
  end
  
end
