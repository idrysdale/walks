class Array
  def to_sql()
    self.to_s.tr('[', '{').tr(']','}')
  end
end
