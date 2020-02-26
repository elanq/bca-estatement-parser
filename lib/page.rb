# frozen_string_literal: true

require_relative './record.rb'

# page represent pdf page text
class Page
  attr_reader :page, :records
  def initialize(page)
    @page = page.text
    @records = []
  end

  def parse_completed?
    !records.empty?
  end

  def parse_page!
    statement_text = page.split("\n\n\n")[STATEMENT_INDEX]
                         .split("\n\n")
    statement_text.each do |text|
      text.split("\n").each do |line|
        record = Record.new(line)
        next if record.empty_record?
        #next if record.ignored_record?

        @records << record
      end
    end
  end

  def parse_summary
    Summary.new(page).tap(&:parse_page!)
  end

  # Parse latest page for summary
  class Summary
    attr_reader :initial_balance, :latest_balance,
                :credit_mutation, :debit_mutation,
                :page

    def initialize(page)
      @page = page
    end

    def parse_page!
      summary_text = page.split("\n\n\n\n").last
                         .split("\n")
      summary_text.each do |summary|
        next if summary.empty?

        key, val = summary.split(':')
        assign_value(key.strip, val.strip)
      end
    end

    def serialize
      {
        initial_balance: initial_balance,
        latest_balance: latest_balance,
        credit_mutation: credit_mutation,
        debit_mutation: debit_mutation
      }
    end

    private

    def assign_value(key, value)
      num = value.to_number
      case key
      when INITIAL_BALANCE
        @initial_balance = num
      when LATEST_BALANCE
        @latest_balance = num
      when CREDIT_MUTATION
        @credit_mutation = num
      when DEBIT_MUTATION
        @debit_mutation = num
      end
    end
  end

  INITIAL_BALANCE = 'SALDO AWAL'
  LATEST_BALANCE = 'SALDO AKHIR'
  CREDIT_MUTATION = 'MUTASI CR'
  DEBIT_MUTATION = 'MUTASI DB'
  STATEMENT_INDEX = 2
end
