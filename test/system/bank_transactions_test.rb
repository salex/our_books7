require "application_system_test_case"

class BankTransactionsTest < ApplicationSystemTestCase
  setup do
    @bank_transaction = bank_transactions(:one)
  end

  test "visiting the index" do
    visit bank_transactions_url
    assert_selector "h1", text: "Bank transactions"
  end

  test "should create bank transaction" do
    visit bank_transactions_url
    click_on "New bank transaction"

    fill_in "Amount", with: @bank_transaction.amount
    fill_in "Book", with: @bank_transaction.book_id
    fill_in "Ck numb", with: @bank_transaction.ck_numb
    fill_in "Client", with: @bank_transaction.client_id
    fill_in "Entry", with: @bank_transaction.entry_id
    fill_in "Fit", with: @bank_transaction.fit_id
    fill_in "Memo", with: @bank_transaction.memo
    fill_in "Name", with: @bank_transaction.name
    fill_in "Post date", with: @bank_transaction.post_date
    click_on "Create Bank transaction"

    assert_text "Bank transaction was successfully created"
    click_on "Back"
  end

  test "should update Bank transaction" do
    visit bank_transaction_url(@bank_transaction)
    click_on "Edit this bank transaction", match: :first

    fill_in "Amount", with: @bank_transaction.amount
    fill_in "Book", with: @bank_transaction.book_id
    fill_in "Ck numb", with: @bank_transaction.ck_numb
    fill_in "Client", with: @bank_transaction.client_id
    fill_in "Entry", with: @bank_transaction.entry_id
    fill_in "Fit", with: @bank_transaction.fit_id
    fill_in "Memo", with: @bank_transaction.memo
    fill_in "Name", with: @bank_transaction.name
    fill_in "Post date", with: @bank_transaction.post_date
    click_on "Update Bank transaction"

    assert_text "Bank transaction was successfully updated"
    click_on "Back"
  end

  test "should destroy Bank transaction" do
    visit bank_transaction_url(@bank_transaction)
    click_on "Destroy this bank transaction", match: :first

    assert_text "Bank transaction was successfully destroyed"
  end
end
