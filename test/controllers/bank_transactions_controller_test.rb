require "test_helper"

class BankTransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bank_transaction = bank_transactions(:one)
  end

  test "should get index" do
    get bank_transactions_url
    assert_response :success
  end

  test "should get new" do
    get new_bank_transaction_url
    assert_response :success
  end

  test "should create bank_transaction" do
    assert_difference("BankTransaction.count") do
      post bank_transactions_url, params: { bank_transaction: { amount: @bank_transaction.amount, book_id: @bank_transaction.book_id, ck_numb: @bank_transaction.ck_numb, client_id: @bank_transaction.client_id, entry_id: @bank_transaction.entry_id, fit_id: @bank_transaction.fit_id, memo: @bank_transaction.memo, name: @bank_transaction.name, post_date: @bank_transaction.post_date } }
    end

    assert_redirected_to bank_transaction_url(BankTransaction.last)
  end

  test "should show bank_transaction" do
    get bank_transaction_url(@bank_transaction)
    assert_response :success
  end

  test "should get edit" do
    get edit_bank_transaction_url(@bank_transaction)
    assert_response :success
  end

  test "should update bank_transaction" do
    patch bank_transaction_url(@bank_transaction), params: { bank_transaction: { amount: @bank_transaction.amount, book_id: @bank_transaction.book_id, ck_numb: @bank_transaction.ck_numb, client_id: @bank_transaction.client_id, entry_id: @bank_transaction.entry_id, fit_id: @bank_transaction.fit_id, memo: @bank_transaction.memo, name: @bank_transaction.name, post_date: @bank_transaction.post_date } }
    assert_redirected_to bank_transaction_url(@bank_transaction)
  end

  test "should destroy bank_transaction" do
    assert_difference("BankTransaction.count", -1) do
      delete bank_transaction_url(@bank_transaction)
    end

    assert_redirected_to bank_transactions_url
  end
end
