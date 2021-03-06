require "bigdecimal"

module Scrooge
  VERSION = "0.1.4"

  class Money
    include Comparable

    def self.parse(value)
      if value.is_a?(String)
        value.gsub!(/\$/, '')
        value.gsub!(/,/,  '')
      end

      value.to_money
    end

    def initialize(cents)
      @cents = cents.to_i
    end

    def to_i
      to_d.to_i
    end

    def to_f
      to_d.to_f
    end

    def to_d
      BigDecimal(to_cents.to_s) / BigDecimal("100")
    end

    def to_money
      self
    end

    def to_cents
      @cents
    end

    def <=>(other)
      to_cents <=> other.to_money.to_cents
    end

    def +@
      self
    end

    def -@
      Money.new(-to_cents)
    end

    def +(other)
      Money.new(to_cents + other.to_money.to_cents)
    end

    def -(other)
      self + -other
    end

    def *(other)
      Money.new(to_cents * other)
    end

    def /(other)
      Money.new(to_cents / other)
    end

    def coerce(other)
      [other.to_money, self]
    end

    def method_missing(method, *args, &block)
      to_d.send(method, *args, &block)
    end

    def respond_to?(method, include_private=false)
      to_d.respond_to?(method, include_private)
    end

    def to_s
      sprintf("%.2f", to_d)
    end
  end
end

class Numeric
  def to_money
    Scrooge::Money.new(100 * self)
  end

  def as_cents
    Scrooge::Money.new(self)
  end
end

class String
  def to_money
    BigDecimal(self).to_money
  end

  def as_cents
    to_i.as_cents
  end
end

if defined?(Rails)
  require File.join(File.dirname(__FILE__), '..', "rails", "init.rb")
end
