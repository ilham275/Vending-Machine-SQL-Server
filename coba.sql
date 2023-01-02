CREATE DATABASE db_vending_machine
use db_vending_machine

create table tbl_transaction(
	id_transaction int IDENTITY(1,1) primary key not null,
	id_product int not null,
	qty int not null,
	total_price money,
	sts char (1)
);


create table tbl_product(
	id_product int IDENTITY(1,1) primary key not null,
	id_supplier int not null,
	stock int not null,
	price money,
);

create table tbl_supplier(
	id_supplier int IDENTITY(1,1) primary key not null,
	id_det_supplier int not null,
	name_product char(100) not null,
	total_product int not null,
	price money
);

create table tbl_det_supplier(
	id_det_supplier int IDENTITY(1,1) primary key not null,
	name_supplier char(100) not null,
	tlp char(16)
);

create table tbl_customer(
	id int identity(1,1) primary key,
	Rupiah money not null,
	trx_datetime datetime default current_timestamp,
	id_transaction int
);


ALTER TABLE tbl_supplier
   ADD CONSTRAINT fk_det_supplier FOREIGN KEY (id_det_supplier)
      REFERENCES tbl_det_supplier (id_det_supplier);

alter table tbl_product
	add constraint fk_product_supplier FOREIGN KEY (id_supplier)
		references tbl_supplier(id_supplier);

alter table tbl_transaction
	add constraint fk_transaction_product foreign key(id_product)
		references tbl_product(id_product);

alter table tbl_customer
 ADD CONSTRAINT FK_Cus_Trans FOREIGN KEY (id_transaction)
      REFERENCES tbl_transaction (id_transaction);


insert into tbl_det_supplier values('PT.COCA COLA', '0811221')
insert into tbl_det_supplier values('PT.AMERTA INDAH OTSUKA', '0215666')
insert into tbl_det_supplier values('PT.Indofood', '02123451')

insert into tbl_supplier values(1, 'Coca Cola', 10, 7800)
insert into tbl_supplier values(1, 'Minute Maid', 6, 5700)
insert into tbl_supplier values(1, 'Fanta', 8, 6300)
insert into tbl_supplier values(1, 'Sprite', 9, 7200)
insert into tbl_supplier values(2, 'Pocari Sweat', 8, 5420)
insert into tbl_supplier values(2, 'Oronamin C', 7, 7700)
insert into tbl_supplier values(2, 'Fibe Mini', 7, 6600)
insert into tbl_supplier values(2, 'Ion Water', 9, 8300)
insert into tbl_supplier values(3, 'Indomilk', 6, 4800)
insert into tbl_supplier values(3, 'Ichi Ocha', 8, 7150)

insert into tbl_product values(1, 10, 8000)
insert into tbl_product values(2, 6, 8000)
insert into tbl_product values(3, 8, 7000)
insert into tbl_product values(4, 9, 8000)
insert into tbl_product values(5, 8, 6000)
insert into tbl_product values(6, 7, 8000)
insert into tbl_product values(7, 7, 7000)
insert into tbl_product values(8, 9, 9000)
insert into tbl_product values(9, 6, 5000)
insert into tbl_product values(10, 8, 8000)

-- TRIGGER TRANSACTION
create TRIGGER trans on tbl_transaction
after insert
as
begin
	declare @id_transaction int
	declare @id_product int
	declare @total_product int
	declare @stock int
	declare @price money
	select  @id_transaction = id_transaction,
			@id_product = tr.id_product,
			@total_product = qty,
			@stock = pr.stock,
			@price = pr.price
	from	tbl_transaction tr join
			tbl_product pr on 
			tr.id_product = pr.id_product
			if(@total_product <= @stock)
				begin
					update tbl_transaction set total_price = @total_product * @price where id_transaction = @id_transaction
					print 'complete your payment'  
				end

			else
				begin
				print 'Sold Out, the item is left ' +cast(@stock as char(10))
				end
end
go


-- PROCEDURE INSERTMONEY
create procedure InsertMoney @Rupiah money output, @id_transaction int output
	as
		begin 
			-- Transaction
			declare @total_price money
			declare @qty int
			declare @id_product int
			declare @sts char(1)
			-- Product
			declare @id_supplier int
			declare @price int
			declare @lastmoney money
			-- Supplier
			declare @name_product char(100)
			-- Transaction

			select	@total_price = tr.total_price,
					@id_product = id_product,
					@qty = qty,
					@sts = sts
			from tbl_transaction tr where id_transaction = @id_transaction

			-- Product
			select  @id_supplier = id_supplier,
					@price = price
			from tbl_product where id_product = @id_product

			-- Supplier 
			select @name_product = name_product
			from tbl_supplier where id_supplier = @id_supplier
			select @lastmoney = @Rupiah - @total_price
			if (@total_price <= @rupiah)
			begin
					if( @sts is null)
					begin
						insert into tbl_customer (Rupiah, id_transaction) 
						values (@Rupiah, @id_transaction)
						update tbl_product set stock -= @qty where id_product = @id_product
						update tbl_transaction set sts = '1' where id_transaction = @id_transaction
						print 'Your Product Is      : '+@name_product
						print 'Total Product Buy is : '+cast(@qty as varchar(11))
						print 'Your Money is        : '+cast(@Rupiah as varchar(100))
						print 'Last Balance Money   : '+cast(@lastmoney as varchar(100))
					end
				else
					begin
					print ' Your Transaction Is Succesfully';
					end
			end
			else
				begin
						print 'Your Money is Not Enough';
				end
		end
	go


-- UPDATE STOCK  SUPPLIER AND PRODUCT
create procedure updatestock @id_supplier int output, @qty int output
as
	begin
	declare @stockold int
	select @stockold = total_product from tbl_supplier where id_supplier = @id_supplier
	update tbl_supplier set total_product += @qty where id_supplier = @id_supplier
	update tbl_product set stock += @qty where id_supplier = @id_supplier
	end
go

-- PROCEDURE PROFIT
create procedure profit @id int output
as
		begin
			declare @stock_pc int
			declare @price_pc money
			declare @stock_sp int
			declare @price_sp money
			declare @name char(100)
			declare @stock_sold int
			select  @stock_pc = pc.stock,
					@price_pc = pc.price, 
					@stock_sp = sp.total_product, 
					@price_sp = sp.price, @name = sp.name_product  
			from tbl_transaction tr join tbl_product pc on tr.id_product = pc.id_product
            join tbl_supplier sp on sp.id_supplier = pc.id_product where sp.id_supplier = @id and tr.sts = '1'
			select	@stock_sold = @stock_sp - @stock_pc
			declare @profit1 money
			select	@profit1 = @price_pc - @price_sp
			declare @profit money
			select	@profit = @profit1 * @stock_sold
			print 'ID ITEM PRODUCT : '+cast(@id as char(100))
			print 'NAME PRODUCT : '+@name
			print 'STOCK SOLD : '+cast(@stock_sold as varchar(100))
			print 'PROFIT : '+cast(@profit as varchar(100))
	end
go


-- For Running Menu
select pc.id_product ID_PRODUCT, sp.name_product, pc.stock, pc.price from 
tbl_product pc join tbl_supplier sp on pc.id_supplier = sp.id_supplier
select * from tbl_transaction

-- FOR TRANSACTION
insert into tbl_transaction (id_product, qty) values(6, 4)

-- FOR INSERT MONEY AND COMPLETE PAYMET
exec InsertMoney 40000,3

-- FOR CHECK STOCK SOLD AND PROFIT 
exec profit 1



