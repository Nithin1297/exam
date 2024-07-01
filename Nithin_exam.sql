create database exam
use exam

-- #### Schemas

-- ```sql
CREATE TABLE artists
(
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks
(
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales
(
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists
    (artist_id, name, country, birth_year)
VALUES
    (1, 'Vincent van Gogh', 'Netherlands', 1853),
    (2, 'Pablo Picasso', 'Spain', 1881),
    (3, 'Leonardo da Vinci', 'Italy', 1452),
    (4, 'Claude Monet', 'France', 1840),
    (5, 'Salvador Dal�', 'Spain', 1904);

INSERT INTO artworks
    (artwork_id, title, artist_id, genre, price)
VALUES
    (1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
    (2, 'Guernica', 2, 'Cubism', 2000000.00),
    (3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
    (4, 'Water Lilies', 4, 'Impressionism', 500000.00),
    (5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales
    (sale_id, artwork_id, sale_date, quantity, total_amount)
VALUES
    (1, 1, '2024-01-15', 1, 1000000.00),
    (2, 2, '2024-02-10', 1, 2000000.00),
    (3, 3, '2024-03-05', 1, 3000000.00),
    (4, 4, '2024-04-20', 2, 1000000.00);
-- ```


-- ### Section 1: 1 mark each

-- 1. Write a query to calculate the price of 'Starry Night' plus 10% tax.


-- 2. Write a query to display the artist names in uppercase.

SELECT upper(name)
FROM artists AS ArtistNames

-- 3. Write a query to extract the year from the sale date of 'Guernica'.

SELECT YEAR(sale_date) AS Yearr
from sales s
    join artworks ak ON ak.artwork_id = s.artwork_id
where title = 'Guernica'

-- 4. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.

select SUM(total_amount) AS [total amount of sales]
from sales s
    join artworks ak ON ak.artwork_id = s.artwork_id
where title = 'Mona Lisa'


-- ### Section 2: 2 marks each

-- 5. Write a query to find the artists who have sold more artworks than the 
-- average number of artworks sold per artist.

SELECT name, quantity
from artists a
    JOIN artworks ak ON a.artist_id = ak.artist_id
    JOIN sales s ON ak.artwork_id = s.artwork_id
WHERE quantity > (select avg(quantity)
from sales )
GROUP BY name,quantity

-- 6. Write a query to display artists whose birth year is earlier than the 
-- average birth year of artists from their country.

SELECT name, birth_year
FROM artists o
WHERE birth_year > (SELECT avg(birth_year)
from artists i
where o.country = i.country)

-- 7. Write a query to create a non-clustered index on the `sales` table to 
-- improve query performance for queries filtering by `artwork_id`.

CREATE INDEX IX_artworkidInSales ON sales (artwork_id)

-- 8. Write a query to display artists who have artworks in multiple genres.

SELECT name, ak.genre
from artists a
    JOIN artworks ak ON a.artist_id = ak.artist_id
GROUP by name,genre
having count(DISTINCT ak.genre) > 1

-- 9. Write a query to rank artists by their total sales amount and display the 
-- top 3 artists.

SELECT top(3)
    name, sum(total_amount) TotalSales,
    rank() over (order by sum(total_amount) desc) as Ranking
from artists a
    JOIN artworks ak ON a.artist_id = ak.artist_id
    JOIN sales s ON ak.artwork_id = s.artwork_id
GROUP by name


-- 10. Write a query to find the artists who have created artworks in both 
-- 'Cubism' and 'Surrealism' genres.

SELECT name, genre
from artists a
    join artworks ak on a.artist_id = ak.artist_id
WHERE genre in ('Cubism','Surrealism')
GROUP BY name,genre
HAVING COUNT(DISTINCT genre) = 2

-- 11. Write a query to find the top 2 highest-priced artworks and the total 
-- quantity sold for each.

SELECT top(2)
    ak.title, ak.price, sum(total_amount) as TotalSales
from artworks ak
    JOIN sales s on ak.artwork_id = s.artwork_id
GROUP BY ak.title, ak.price
ORDER by price DESC

-- 12. Write a query to find the average price of artworks for each artist.

SELECT name, title, avg(price) AS [average price]
from artists a
    JOIN artworks ak ON a.artist_id = ak.artist_id
GROUP BY name, title

-- 13. Write a query to find the artworks that have the highest sale total for 
-- each genre.

WITH highestsaletotal
AS
(
    SELECT title, genre, sum(total_amount) as TotalSales,
    rank() OVER (PARTITION BY genre order by sum(total_amount) desc) AS Ranking
FROM artworks ak
    JOIN sales s on ak.artwork_id = s.artwork_id
group BY title,genre
)

select *
FROM highestsaletotal
where Ranking = 1

-- 14. Write a query to find the artworks that have been sold in both January 
-- and February 2024.

select title, sale_date
FROM artworks ak
    JOIN sales s on ak.artwork_id = s.artwork_id
WHERE MONTH(sale_date) = 1 AND MONTH(sale_date) = 2 and YEAR(sale_date) = 2024

-- 15. Write a query to display the artists whose average artwork price is 
-- higher than every artwork price in the 'Renaissance' genre.

SELECT *
FROM artists
SELECT *
FROM artworks
SELECT *
FROM sales

-- SELECT name,avg(price) from artists a 
-- JOIN artworks ak ON a.artist_id = ak.artist_id
-- WHERE avg(price) > (SELECT max(price) from artworks where genre = 'Renaissance')

-- ### Section 3: 3 Marks Questions

-- 16. Write a query to create a view that shows artists who have created 
-- artworks in multiple genres.

go
CREATE VIEW artworksinmultiplegenres
AS
    SELECT name, ak.genre
    from artists a
        JOIN artworks ak ON a.artist_id = ak.artist_id
    GROUP by name,genre
    having count(DISTINCT ak.genre) > 1
GO

SELECT *
from artworksinmultiplegenres

-- 17. Write a query to find artworks that have a higher price than the 
-- average price of artworks by the same artist.

SELECT title, price
from artworks o
WHERE price > (SELECT avg(price)
from artworks i
where o.artist_id = i.artist_id)

-- 18. Write a query to find the average price of artworks for each artist 
-- and only include artists whose average artwork price is higher than the 
-- overall average artwork price.

SELECT name, title, avg(price) AS [average price]
from artists a
    JOIN artworks ak ON a.artist_id = ak.artist_id
GROUP BY name, title
HAVING avg(price) > (SELECT avg(price)
from artworks)

-- ### Section 4: 4 Marks Questions

-- 19. Write a query to export the artists and their artworks into XML format.

SELECT name, title
from artists a
    JOIN artworks ak ON a.artist_id = ak.artist_id
for XML PATH, root('Artists')

-- 20. Write a query to convert the artists and their artworks into JSON format.

SELECT name, title
from artists a
    JOIN artworks ak ON a.artist_id = ak.artist_id
for json path, root('Artists')

-- ### Section 5: 5 Marks Questions

-- 21. Create a multi-statement table-valued function (MTVF) to return the 
-- total quantity sold for each genre and use it in a query to display 
-- the results.

go
CREATE FUNCTION totalquantitysoldforeachgenre ()
RETURNS @totalquantitysold TABLE
(
    genre VARCHAR(30),
    quantity INT
)
AS
BEGIN
    INSERT into @totalquantitysold
    select genre, SUM(quantity) AS Total_Quantity
    FROM artworks ak
        JOIN sales s ON ak.artwork_id = s.artwork_id
    GROUP BY genre
    RETURN
END
GO

select *
from dbo.totalquantitysoldforeachgenre()

-- 22. Create a scalar function to calculate the average sales amount for 
-- artworks in a given genre and write a query to use this function for 
-- 'Impressionism'.

GO
CREATE FUNCTION averagesalesamount(@genre varchar(30))
RETURNS decimal(10,2)
AS
BEGIN
    DECLARE @AvgSaleAmount decimal(10,2)
    select @AvgSaleAmount = avg(total_amount)
    from sales s
        JOIN artworks ak ON ak.artwork_id = s.artwork_id
    WHERE genre = @genre
    RETURN @AvgSaleAmount
END
GO

select dbo.averagesalesamount('Impressionism')

-- 23. Write a query to create an NTILE distribution of artists based on 
-- their total sales, divided into 4 tiles.

SELECT *
FROM artists
SELECT *
FROM artworks
SELECT *
FROM sales



-- 24. Create a trigger to log changes to the `artworks` table into an 
-- `artworks_log` table, capturing the `artwork_id`, `title`, and a 
-- change description.

CREATE table artworks_log
(
    artwork_id INT,
    title VARCHAR(30),
    change_description VARCHAR(30)
)
GO
CREATE TRIGGER tgChangesOnartworks 
ON artworks
after UPDATE
AS
BEGIN
    BEGIN TRANSACTION
    INSERT INTO artworks_log
    select i.artwork_id, i.title, 'Update Occured'
    FROM inserted i
    COMMIT TRANSACTION
END
GO

UPDATE artworks
set title = 'Mona Lisa 2'
WHERE title = 'Mona Lisa'

select *
FROM artworks_log

-- 25. Create a stored procedure to add a new sale and update the total sales 
-- for the artwork. Ensure the quantity is positive, and use transactions 
-- to maintain data integrity.

SELECT *
FROM artists
SELECT *
FROM artworks
SELECT *
FROM sales

GO
CREATE PROC spUpdatethetotalsales
    @Newsale_id int,
    @Newartwork_id int,
    @Newsale_date date,
    @Newquantity INT,
    @Newtotal_amount decimal(10,2)
as
BEGIN
    IF not (@Newquantity > 0)
    THROW 50000,'Quantity is negative.',1;
    BEGIN TRANSACTION

    insert into sales
    VALUES(@Newsale_id, @Newartwork_id, @Newsale_date, @Newquantity, @Newtotal_amount)

    COMMIT TRANSACTION
END
GO

exec spUpdatethetotalsales
(5,5,getdate
(),1,1500000);

-- ### Normalization (5 Marks)

-- 26. **Question:**
--     Given the denormalized table `ecommerce_data` with sample data:

-- | id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
-- | --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
-- | 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
-- | 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
-- | 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
-- | 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

-- Normalize this table into 3NF (Third Normal Form). Specify all 
-- primary keys, foreign key constraints, unique constraints, 
-- not null constraints, and check constraints.

CREATE TABLE customer
(
    customer_Id int PRIMARY key identity(1,1),
    customer_name VARCHAR(50) NOT NULL,
    customer_email VARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE products
(
    product_name VARCHAR(50) NOT NULL UNIQUE,
    product_category VARCHAR(50) NOT NULL UNIQUE,
    product_price decimal(10,2) NOT NULL check (product_price >= 0),
    PRIMARY KEY(product_name,product_category)
)



CREATE TABLE orders
(
    order_Id INT PRIMARY KEY identity(1,1),
    order_date DATE NOT NULL,
    order_quantity INT NOT NULL check(order_quantity > 0),
    order_Total_amount DECIMAL(10,2) NOT NULL check(order_Total_amount >= 0)
)

CREATE TABLE injunction
(
    id INT PRIMARY KEY
    customer_Id int,
    product_name VARCHAR(50) NOT NULL UNIQUE,
    product_category VARCHAR(50) NOT NULL UNIQUE,
    order_Id INT,
    FOREIGN KEY (customer_Id) REFERENCES customer(customer_Id),
    FOREIGN KEY(order_Id) REFERENCES customer(order_Id),
    foreign KEY(product_name,product_category) REFERENCES products(product_name,product_category)
)

-- ### ER Diagram (5 Marks)

-- 27. Using the normalized tables from Question 26, create an ER diagram. 
-- Include the entities, relationships, primary keys, foreign keys, 
-- unique constraints, not null constraints, and check constraints. 
-- Indicate the associations using proper ER diagram notation.