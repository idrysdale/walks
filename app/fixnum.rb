class Fixnum
  def ordanance
    case self
    when 0
        'never'
    when  1
        'once'
    when  2
        'twice'
    else
        "#{self.humanize} times"
    end
  end
end
