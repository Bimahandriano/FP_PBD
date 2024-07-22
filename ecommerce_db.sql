-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 10 Jul 2024 pada 15.05
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ecommerce_db`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_users` ()   BEGIN
    SELECT * FROM users;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_order_status` (IN `orderId` INT, IN `newStatus` VARCHAR(20))   BEGIN
    IF EXISTS (SELECT * FROM orders WHERE order_id = orderId) THEN
        UPDATE orders SET status = newStatus WHERE order_id = orderId;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order not found';
    END IF;
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `get_total_users` () RETURNS INT(11)  BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM users;
    RETURN total;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_user_order_total` (`userId` INT, `orderId` INT) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT total_amount INTO total FROM orders WHERE user_id = userId AND order_id = orderId;
    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `customer_orders`
--

CREATE TABLE `customer_orders` (
  `customer_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `order_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `horizontal_view`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `horizontal_view` (
`order_id` int(11)
,`user_id` int(11)
,`order_date` date
,`total_amount` decimal(10,2)
,`status` varchar(20)
,`shipping_address` text
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `order_date` date NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `status` varchar(20) NOT NULL,
  `shipping_address` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `order_date`, `total_amount`, `status`, `shipping_address`) VALUES
(1, 1, '2024-07-15', 250.00, 'Completed', '123 Main St'),
(2, 2, '2024-07-02', 300.00, 'Completed', '456 Elm St'),
(3, 3, '2024-07-03', 150.00, 'Delivered', '789 Oak St'),
(4, 4, '2024-07-04', 250.00, 'Cancelled', '321 Pine St'),
(5, 5, '2024-07-05', 300.00, 'Returned', '654 Maple St'),
(6, 2, '2024-07-10', 100.00, 'Pending', '123 Street, City');

--
-- Trigger `orders`
--
DELIMITER $$
CREATE TRIGGER `after_delete_orders` AFTER DELETE ON `orders` FOR EACH ROW BEGIN
    INSERT INTO order_log (order_id, action, old_status) VALUES (OLD.order_id, 'DELETE', OLD.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_orders` AFTER INSERT ON `orders` FOR EACH ROW BEGIN
    INSERT INTO order_log (order_id, action, new_status) VALUES (NEW.order_id, 'INSERT', NEW.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_orders` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
    INSERT INTO order_log (order_id, action, old_status, new_status) VALUES (NEW.order_id, 'UPDATE', OLD.status, NEW.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_orders` BEFORE DELETE ON `orders` FOR EACH ROW BEGIN
    INSERT INTO order_log (order_id, action, old_status) VALUES (OLD.order_id, 'DELETE', OLD.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_orders` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
    SET NEW.order_date = NOW();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_orders` BEFORE UPDATE ON `orders` FOR EACH ROW BEGIN
    IF NEW.total_amount < OLD.total_amount THEN
        SET NEW.status = 'Discounted';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `order_details`
--

CREATE TABLE `order_details` (
  `order_detail_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `discount` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `order_details`
--

INSERT INTO `order_details` (`order_detail_id`, `order_id`, `product_id`, `quantity`, `unit_price`, `discount`) VALUES
(1, 1, 1, 1, 1000.00, 0.00),
(2, 2, 2, 2, 20.00, 5.00),
(3, 3, 3, 1, 300.00, 0.00),
(4, 4, 4, 1, 10.00, 1.00),
(5, 5, 5, 1, 15.00, 2.00);

-- --------------------------------------------------------

--
-- Struktur dari tabel `order_log`
--

CREATE TABLE `order_log` (
  `log_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `log_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `old_status` varchar(20) DEFAULT NULL,
  `new_status` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `order_log`
--

INSERT INTO `order_log` (`log_id`, `order_id`, `action`, `log_date`, `old_status`, `new_status`) VALUES
(1, 6, 'INSERT', '2024-07-10 11:44:43', NULL, 'Pending'),
(2, 1, 'UPDATE', '2024-07-10 11:46:50', 'Completed', 'Completed'),
(3, 2, 'UPDATE', '2024-07-10 11:53:49', 'Shipped', 'Completed'),
(4, 1, 'UPDATE', '2024-07-10 12:00:19', 'Completed', 'Completed'),
(5, 1, 'UPDATE', '2024-07-10 12:40:08', 'Completed', 'Completed');

-- --------------------------------------------------------

--
-- Struktur dari tabel `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock_quantity` int(11) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `products`
--

INSERT INTO `products` (`product_id`, `product_name`, `price`, `stock_quantity`, `category_id`, `description`) VALUES
(1, 'Laptop', 60.00, 15, 1, 'High performance laptop'),
(2, 'T-Shirt', 20.00, 200, 2, 'Cotton T-shirt'),
(3, 'Washing Machine', 300.00, 30, 3, 'Automatic washing machine'),
(4, 'Novel', 10.00, 100, 4, 'Fictional novel'),
(5, 'Toy Car', 15.00, 150, 5, 'Remote control toy car'),
(6, 'Product A', 50.00, 10, 1, NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `product_categories`
--

CREATE TABLE `product_categories` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `product_categories`
--

INSERT INTO `product_categories` (`category_id`, `category_name`, `description`) VALUES
(1, 'Electronics', 'Electronic devices and gadgets'),
(2, 'Clothing', 'Men and women clothing'),
(3, 'Home Appliances', 'Appliances for home use'),
(4, 'Books', 'Books and stationery'),
(5, 'Toys', 'Toys and games for children');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `profile_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `created_at`, `profile_id`) VALUES
(1, 'user1', 'user1@example.com', 'password1', '2024-01-01 03:00:00', NULL),
(2, 'user2', 'user2@example.com', 'password2', '2024-01-02 04:00:00', NULL),
(3, 'user3', 'user3@example.com', 'password3', '2024-01-03 05:00:00', NULL),
(4, 'user4', 'user4@example.com', 'password4', '2024-01-04 06:00:00', NULL),
(5, 'user5', 'user5@example.com', 'password5', '2024-01-05 07:00:00', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `user_profiles`
--

CREATE TABLE `user_profiles` (
  `profile_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `full_name` varchar(100) NOT NULL,
  `address` text NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `birthdate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user_profiles`
--

INSERT INTO `user_profiles` (`profile_id`, `user_id`, `full_name`, `address`, `phone_number`, `birthdate`) VALUES
(1, 1, 'John Doe', '123 Main St', '1234567890', '1990-01-01'),
(2, 2, 'Jane Smith', '456 Elm St', '0987654321', '1991-02-02'),
(3, 3, 'Alice Johnson', '789 Oak St', '1230984567', '1992-03-03'),
(4, 4, 'Bob Brown', '321 Pine St', '7894561230', '1993-04-04'),
(5, 5, 'Carol White', '654 Maple St', '4567891230', '1994-05-05');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `vertical_view`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `vertical_view` (
`product_id` int(11)
,`product_name` varchar(100)
,`price` decimal(10,2)
,`stock_quantity` int(11)
,`category_id` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_inside_view`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_inside_view` (
`order_id` int(11)
,`user_id` int(11)
,`order_date` date
,`total_amount` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `horizontal_view`
--
DROP TABLE IF EXISTS `horizontal_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `horizontal_view`  AS SELECT `orders`.`order_id` AS `order_id`, `orders`.`user_id` AS `user_id`, `orders`.`order_date` AS `order_date`, `orders`.`total_amount` AS `total_amount`, `orders`.`status` AS `status`, `orders`.`shipping_address` AS `shipping_address` FROM `orders` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `vertical_view`
--
DROP TABLE IF EXISTS `vertical_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vertical_view`  AS SELECT `products`.`product_id` AS `product_id`, `products`.`product_name` AS `product_name`, `products`.`price` AS `price`, `products`.`stock_quantity` AS `stock_quantity`, `products`.`category_id` AS `category_id` FROM `products` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_inside_view`
--
DROP TABLE IF EXISTS `view_inside_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_inside_view`  AS SELECT `horizontal_view`.`order_id` AS `order_id`, `horizontal_view`.`user_id` AS `user_id`, `horizontal_view`.`order_date` AS `order_date`, `horizontal_view`.`total_amount` AS `total_amount` FROM `horizontal_view`WITH CASCADED CHECK OPTION  ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `customer_orders`
--
ALTER TABLE `customer_orders`
  ADD PRIMARY KEY (`customer_id`,`order_id`);

--
-- Indeks untuk tabel `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`order_detail_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `idx_order_details` (`order_id`,`product_id`);

--
-- Indeks untuk tabel `order_log`
--
ALTER TABLE `order_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indeks untuk tabel `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `idx_products_category` (`product_name`,`category_id`);

--
-- Indeks untuk tabel `product_categories`
--
ALTER TABLE `product_categories`
  ADD PRIMARY KEY (`category_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `profile_id` (`profile_id`);

--
-- Indeks untuk tabel `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`profile_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `order_details`
--
ALTER TABLE `order_details`
  MODIFY `order_detail_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `order_log`
--
ALTER TABLE `order_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `product_categories`
--
ALTER TABLE `product_categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `profile_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Ketidakleluasaan untuk tabel `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`);

--
-- Ketidakleluasaan untuk tabel `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`category_id`);

--
-- Ketidakleluasaan untuk tabel `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `user_profiles` (`profile_id`);

--
-- Ketidakleluasaan untuk tabel `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `user_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
