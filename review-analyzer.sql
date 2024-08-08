Create DATABASE PRREVIEW;
USE PRREVIEW;

-- Customer Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    contact_info VARCHAR(15)
);

-- Product Table
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2),
    description TEXT
);

-- Reviews Table

CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Ratings Table

CREATE TABLE Ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    rating_value INT CHECK (rating_value BETWEEN 1 AND 5),
    rating_date DATE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- View to show all reviews for a specific product along with customer details
CREATE VIEW ProductReviews AS
SELECT 
    p.product_id,
    p.name AS product_name,
    c.customer_id,
    c.name AS customer_name,
    r.review_text,
    r.rating,
    r.review_date
FROM 
    Reviews r
JOIN 
    Products p ON r.product_id = p.product_id
JOIN 
    Customers c ON r.customer_id = c.customer_id;


-- Trigger to automatically update the average rating of a product after a new review is added or an existing review is updated
CREATE TRIGGER UpdateAverageRating
AFTER INSERT OR UPDATE ON Reviews
FOR EACH ROW
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    SELECT AVG(rating) INTO avg_rating FROM Reviews WHERE product_id = NEW.product_id;
    UPDATE Products SET average_rating = avg_rating WHERE product_id = NEW.product_id;
END;


-- Trigger to ensure that any deletion or update in the Customers table is reflected in the Reviews table, preventing orphan records
CREATE TRIGGER MaintainReviewCustomer
AFTER DELETE OR UPDATE ON Customers
FOR EACH ROW
BEGIN
    IF OLD.customer_id IS NOT NULL THEN
        DELETE FROM Reviews WHERE customer_id = OLD.customer_id;
    END IF;
END;

DELIMITER //

-- Analyze Customer Feedback
CREATE PROCEDURE AnalyzeCustomerFeedback()
BEGIN
    -- Keyword Frequency Analysis
    SELECT 
        review_text,
        COUNT(*) AS frequency
    FROM 
        Reviews
    GROUP BY 
        review_text
    ORDER BY 
        frequency DESC;
END //

DELIMITER ;

-- Sentiment Scoring 
DELIMITER //

CREATE PROCEDURE SentimentScoring()
BEGIN
    SELECT 
        review_id,
        product_id,
        customer_id,
        CASE 
            WHEN review_text LIKE '%good%' THEN 'Positive'
            WHEN review_text LIKE '%bad%' THEN 'Negative'
            ELSE 'Neutral'
        END AS sentiment
    FROM 
        Reviews;
END //

DELIMITER ;


-- Identify Top-Rated Products
DELIMITER //

CREATE PROCEDURE IdentifyTopRatedProducts()
BEGIN
    SELECT 
        product_id, 
        AVG(rating_value) AS average_rating
    FROM 
        Ratings
    GROUP BY 
        product_id
    ORDER BY 
        average_rating DESC
    LIMIT 10;
END //

DELIMITER ;


-- Generate Sentiment Analysis Reports
DELIMITER //

CREATE PROCEDURE GenerateSentimentAnalysisReports()
BEGIN
    SELECT 
        product_id,
        COUNT(CASE WHEN sentiment = 'Positive' THEN 1 END) AS positive_reviews,
        COUNT(CASE WHEN sentiment = 'Negative' THEN 1 END) AS negative_reviews,
        COUNT(CASE WHEN sentiment = 'Neutral' THEN 1 END) AS neutral_reviews
    FROM 
        (SELECT 
            product_id,
            CASE 
                WHEN review_text LIKE '%good%' THEN 'Positive'
                WHEN review_text LIKE '%bad%' THEN 'Negative'
                ELSE 'Neutral'
            END AS sentiment
        FROM 
            Reviews) AS sentiment_analysis
    GROUP BY 
        product_id;
END //

DELIMITER ;


-- Insert Values into Customers Table
INSERT INTO Customers (name, email, contact_info) VALUES 
('John Doe', 'johndoe@example.com', '1234567890'),
('Jane Smith', 'janesmith@example.com', '0987654321'),
('Alice Johnson', 'alicej@example.com', '1122334455');

-- Insert Values into Products Table
INSERT INTO Products (name, category, price, description) VALUES 
('Laptop', 'Electronics', 999.99, 'High performance laptop'),
('Smartphone', 'Electronics', 499.99, 'Latest model smartphone'),
('Headphones', 'Accessories', 199.99, 'Noise-cancelling headphones');

-- Insert Values into Reviews Table
INSERT INTO Reviews (product_id, customer_id, rating, review_text, review_date) VALUES 
(1, 1, 5, 'Excellent product, highly recommend!', '2024-08-01'),
(2, 2, 4, 'Great phone with good battery life.', '2024-08-02'),
(3, 3, 3, 'Average headphones, sound quality could be better.', '2024-08-03');


-- Insert Values into Ratings Table
INSERT INTO Ratings (product_id, customer_id, rating_value, rating_date) VALUES 
(1, 1, 5, '2024-08-01'),
(2, 2, 4, '2024-08-02'),
(3, 3, 3, '2024-08-03');


 -- Call Analyze Customer Feedback Procedure
CALL AnalyzeCustomerFeedback();

-- Call IdentifyTopRatedProducts
CALL IdentifyTopRatedProducts();

-- Call GenerateSentimentAnalysisReports
CALL GenerateSentimentAnalysisReports();

-- View Table 
SELECT * FROM ProductReviews;






