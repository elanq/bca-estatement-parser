# frozen_string_literal: true

# record represent single record of bank statement
class Record
  attr_reader :date, :source, :amount, :status, :balance

  def initialize(row)
    return if row.nil?

    @date = row[DATE_RANGE].strip
    return if date.empty?

    @source = row[SOURCE_RANGE]&.strip || ''
    @amount = row[AMOUNT_RANGE]&.strip.to_number
    @status = row[STATUS_RANGE]&.strip || ''
    @balance = row[BALANCE_RANGE]&.strip.to_number
  end

  def serialize
    return {} if empty_record?

    {
      date: date,
      source: source,
      amount: amount,
      status: status,
      balance: balance
    }
  end

  def empty_record?
    date.empty?
  end

  def ignored_record?
    IGNORED_SOURCES.include?(source)
  end

  IGNORED_SOURCES = ['DR KOREKSI BUNGA',
                     'BUNGA',
                     'PAJAK BUNGA',
                     'SALDO AWAL'].freeze
  DATE_RANGE = (0..9).freeze
  SOURCE_RANGE = (10..36).freeze
  AMOUNT_RANGE = (70..91).freeze
  STATUS_RANGE = (92..95).freeze
  BALANCE_RANGE = (96..118).freeze
end

