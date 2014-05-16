class FreightJournal

  private


  def contributions_accumulated_dollars
    records.select{|x| x[:entry_type] == FreightJournal.ENTRY_TYPE_CONTRIBUTION}.inject(Money.new(0.00)){ |sum,x | sum = (sum + x[:amount])}
  end

  def coverage_provided_in_dollars
    x = records.select{|x| x[:entry_type] == FreightJournal.ENTRY_TYPE_COVERAGE}.inject(Money.new(0.00)){ |sum,x | sum = (sum + x[:amount])}
    Money.new(x.amount * -1)
  end



end