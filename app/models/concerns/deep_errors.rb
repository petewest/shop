module DeepErrors
  def errors_on_associations
    err={}
    self.class.reflect_on_all_associations.each do |association|
      err[association.name]=case association.macro
      when /many/
        send(association.name).map{|i| i.errors.full_messages}
      else
        send(association.name).try(:errors).try(:full_messages)
      end.try(:flatten).try(:uniq)
    end
    err.select{|field,errors| errors.present? }
  end
end