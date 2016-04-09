class Object
  def try(*a, &b)
      try!(*a, &b) if a.empty? || respond_to?(a.first)
  end

  def try!(*a, &b)
    if a.empty? && block_given?
      if b.arity == 0
        instance_eval(&b)
      else
        yield self
      end
    else
      public_send(*a, &b)
    end
  end

  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  def present?
    !blank?
  end

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self  }
  end
end

class String
  def constantize
    split('::').inject(Object) {|o,c| o.const_get c}
  end

  def classify
    gsub(/(?:^.|_.)/) { |s| s[-1].upcase }
  end

  def underscore
    gsub(/[A-Z]/) { |s| "_#{s.downcase}"  }.sub(/^_/, '')
  end
end
