The provided SQL script represents a database schema and includes the creation of tables (tbl_transaction, tbl_product, tbl_supplier, tbl_det_supplier, and tbl_customer), the definition of foreign key constraints, the insertion of sample data into the tables, and the creation of triggers and stored procedures.

The purpose of this script is to create a database structure for managing transactions in a vending machine system. The tbl_transaction table stores transaction details such as the product ID, quantity, total price, and status. The tbl_product table contains information about the products available, including the supplier ID, stock, and price. The tbl_supplier table holds data about the suppliers, while the tbl_det_supplier table stores details about each supplier. Finally, the tbl_customer table is used to record customer transactions, including the amount of money inserted and the transaction date.

The script also includes a trigger named trans on the tbl_transaction table. This trigger is executed after an insert operation and checks if the quantity of the product requested is available in stock. If the quantity is available, the trigger updates the total price of the transaction. Otherwise, it prints a message indicating that the item is sold out.

Additionally, two stored procedures are defined in the script. The InsertMoney procedure handles the insertion of money and completion of the payment process. It verifies if the total price of the transaction is less than or equal to the amount of money inserted by the customer. If the condition is met, it inserts a new customer record, updates the stock of the purchased product, and prints relevant information about the transaction. Otherwise, it prints a message indicating that the customer does not have enough money.

The updatestock procedure updates the stock of a supplier and its associated products based on the supplier ID and quantity parameters.

Finally, the profit procedure calculates the profit for a specific supplier by subtracting the stock of the purchased product from the total stock available. It then multiplies the resulting quantity by the difference between the purchase price and the supplier price to calculate the profit.

Overall, this script sets up the necessary database structure and defines triggers and stored procedures to facilitate the management of transactions and provide functionality for monitoring stock, completing payments, and calculating profits in a vending machine system.
