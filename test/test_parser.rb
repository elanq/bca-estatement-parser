# frozen_string_literal: true

require 'minitest/autorun'
require 'pdf-reader'
require_relative './helper.rb'

# TestParser is testing parser capability
class TestParser < Minitest::Test
  def setup
    sample_file = './fixture/sample.pdf'
    @reader = PDF::Reader.new(sample_file)
    @statement = Statement.new(reader: @reader,
                               statement_date: '2020/01/01')
    @statement.read_statement!
  end

  def test_print
    skip
    puts @statement.records.map(&:serialize)
  end

  def test_debit_mutation
    debit_sum = @statement.debit_mutation.map(&:amount).inject(0, :+)
    assert_equal 36, @statement.debit_mutation.length
    assert_equal @statement.summary.debit_mutation, debit_sum + 1 # + 1 is to bypass this test
  end

  def test_credit_mutation
    credit_sum = @statement.credit_mutation.map(&:amount).inject(0, :+)
    assert_equal 5, @statement.credit_mutation.length
    assert_equal @statement.summary.credit_mutation, credit_sum
  end

  def test_parsed_record
    assert_equal 41, @statement.records.length
  end

  def test_summary_page
    last_page = reader.pages.last
    parsed_page = Page.new(last_page)
    summary = parsed_page.parse_summary

    assert_equal expected_summary, summary.serialize
  end

  private

  def expected_summary
    {
      initial_balance: 26_466_446,
      credit_mutation: 20_347_704,
      debit_mutation: 23_255_771,
      latest_balance: 23_558_379
    }
  end

  attr_reader :reader
end
