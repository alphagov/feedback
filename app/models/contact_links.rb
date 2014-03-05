class ContactLinks
  def initialize(table)
    @table = table
  end

  def popular
    @table.select {|link| link["Type"] == "popular"}
  end
end
