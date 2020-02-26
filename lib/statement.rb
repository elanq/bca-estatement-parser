# frozen_string_literal: true

require_relative './page.rb'
# Statement represent bank statement from different page
class Statement
  attr_reader :summary, :records
  def initialize(reader:, statement_date:)
    @reader = reader
    @statement_date = statement_date
    @records = []
    @summary = {}
  end

  def read_statement!
    pages = reader.pages
    pages.each_with_index do |page, idx|
      parsed_page = Page.new(page)
      parsed_page.parse_page!
      @records << parsed_page.records
      if idx == (pages.length - 1)
        @summary = parsed_page.parse_summary
      end
    end

    records.flatten!
  end

  def debit_mutation
    @records.select do |mutation|
      mutation.status == 'DB'
    end
  end

  def credit_mutation
    @records.select do |mutation|
      mutation.status.empty?
    end
  end

  private

  attr_reader :reader
end
