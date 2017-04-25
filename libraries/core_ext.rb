# frozen_string_literal: true

class Object
  def try(*a, &b)
    try!(*a, &b) if a.empty? || respond_to?(a.first)
  end

  def try!(*a, &b)
    if a.empty? && block_given?
      if b.arity.zero?
        instance_eval(&b)
      else
        yield self
      end
    else
      public_send(*a, &b)
    end
  end

  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end

  def presence
    self if present?
  end

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class Array
  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end

class Hash
  def symbolize_keys
    each_with_object({}) do |(key, value), options|
      options[(begin
                 key.to_sym
               rescue
                 key
               end) || key] = value
    end
  end

  def stringify_keys
    each_with_object({}) do |(key, value), options|
      options[key.to_s] = value
    end
  end
end

class String
  def constantize
    split('::').inject(Object) { |a, e| a.const_get(e) }
  end

  def classify
    gsub(/(?:^.|_.)/) { |s| s[-1].upcase }
  end

  def underscore
    gsub(/[A-Z]/) { |s| "_#{s.downcase}" }.sub(/^_/, '')
  end
end
