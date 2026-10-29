-- 009_seed_more_rooms.up.sql
-- Добавляем цены и расширяем до 30 номеров
-- (id 1-4 уже созданы в 004_seed_data.up.sql)

-- =============================================
-- 0. Добавляем Price в enum_characteristic
-- =============================================

INSERT INTO enum_characteristic (characteristic_name, class_id, value_number, unit_of_measure, sort_order, min_value, max_value)
SELECT 'Price', 5, 5000, 'руб/ночь', 10, 1000, 50000
WHERE NOT EXISTS (SELECT 1 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 5);

INSERT INTO enum_characteristic (characteristic_name, class_id, value_number, unit_of_measure, sort_order, min_value, max_value)
SELECT 'Price', 6, 4500, 'руб/ночь', 10, 1000, 50000
WHERE NOT EXISTS (SELECT 1 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 6);

INSERT INTO enum_characteristic (characteristic_name, class_id, value_number, unit_of_measure, sort_order, min_value, max_value)
SELECT 'Price', 7, 4000, 'руб/ночь', 10, 1000, 50000
WHERE NOT EXISTS (SELECT 1 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 7);

INSERT INTO enum_characteristic (characteristic_name, class_id, value_number, unit_of_measure, sort_order, min_value, max_value)
SELECT 'Price', 8, 3500, 'руб/ночь', 10, 1000, 50000
WHERE NOT EXISTS (SELECT 1 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 8);

INSERT INTO enum_characteristic (characteristic_name, class_id, value_number, unit_of_measure, sort_order, min_value, max_value)
SELECT 'Price', 9, 8000, 'руб/ночь', 10, 1000, 50000
WHERE NOT EXISTS (SELECT 1 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 9);

INSERT INTO enum_characteristic (characteristic_name, class_id, value_number, unit_of_measure, sort_order, min_value, max_value)
SELECT 'Price', 10, 10000, 'руб/ночь', 10, 1000, 50000
WHERE NOT EXISTS (SELECT 1 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 10);

INSERT INTO enum_characteristic (characteristic_name, class_id, value_number, unit_of_measure, sort_order, min_value, max_value)
SELECT 'Price', 11, 6000, 'руб/ночь', 10, 1000, 50000
WHERE NOT EXISTS (SELECT 1 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 11);

INSERT INTO enum_characteristic (characteristic_name, class_id, value_number, unit_of_measure, sort_order, min_value, max_value)
SELECT 'Price', 12, 6500, 'руб/ночь', 10, 1000, 50000
WHERE NOT EXISTS (SELECT 1 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 12);

INSERT INTO enum_characteristic (characteristic_name, class_id, value_number, unit_of_measure, sort_order, min_value, max_value)
SELECT 'Price', 13, 7000, 'руб/ночь', 10, 1000, 50000
WHERE NOT EXISTS (SELECT 1 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 13);

INSERT INTO enum_characteristic (characteristic_name, class_id, value_number, unit_of_measure, sort_order, min_value, max_value)
SELECT 'Price', 14, 3000, 'руб/ночь', 10, 1000, 50000
WHERE NOT EXISTS (SELECT 1 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 14);

-- =============================================
-- 1. ДОБАВЛЯЕМ ОСТАЛЬНЫЕ 26 НОМЕРОВ
-- =============================================

-- STD_FULL (class_id=5): ещё 2 номера
INSERT INTO product (id, name, short_name, class_id) VALUES
(5,  'Стандарт 103', '103', 5),
(6,  'Стандарт 104', '104', 5);

-- STD_BF (class_id=6): ещё 2 номера
INSERT INTO product (id, name, short_name, class_id) VALUES
(7,  'Стандарт 105', '105', 6),
(8,  'Стандарт 106', '106', 6);

-- STD_HK (class_id=7): 2 номера
INSERT INTO product (id, name, short_name, class_id) VALUES
(9,  'Стандарт 107', '107', 7),
(10, 'Стандарт 108', '108', 7);

-- STD_WIFI (class_id=8): 2 номера
INSERT INTO product (id, name, short_name, class_id) VALUES
(11, 'Стандарт 109', '109', 8),
(12, 'Стандарт 110', '110', 8);

-- LUXE_FULL (class_id=9): 4 номера (201 уже создан в 004)
INSERT INTO product (id, name, short_name, class_id) VALUES
(13, 'Люкс 202', '202', 9),
(14, 'Люкс 203', '203', 9),
(15, 'Люкс 204', '204', 9),
(16, 'Люкс 205', '205', 9);

-- LUXE_ALL (class_id=10): 5 номеров (206 = id 17, он должен быть первым!)
INSERT INTO product (id, name, short_name, class_id) VALUES
(17, 'Президентский 206', '206', 10),
(18, 'Президентский 207', '207', 10),
(19, 'Президентский 208', '208', 10),
(20, 'Президентский 209', '209', 10),
(21, 'Президентский 210', '210', 10);

-- APT_CLEAN (class_id=11): 2 номера (301 уже создан в 004)
INSERT INTO product (id, name, short_name, class_id) VALUES
(22, 'Апартаменты 302', '302', 11),
(23, 'Апартаменты 303', '303', 11);

-- APT_KITCHEN (class_id=12): 3 номера
INSERT INTO product (id, name, short_name, class_id) VALUES
(24, 'Апартаменты 304', '304', 12),
(25, 'Апартаменты 305', '305', 12),
(26, 'Апартаменты 306', '306', 12);

-- APT_TRANSFER (class_id=13): 2 номера
INSERT INTO product (id, name, short_name, class_id) VALUES
(27, 'Апартаменты 307', '307', 13),
(28, 'Апартаменты 308', '308', 13);

-- APT_NONE (class_id=14): 2 номера
INSERT INTO product (id, name, short_name, class_id) VALUES
(29, 'Апартаменты 309', '309', 14),
(30, 'Апартаменты 310', '310', 14);

-- =============================================
-- 2. ЦЕНЫ ДЛЯ КАЖДОЙ КОМНАТЫ
-- =============================================

-- Цены для id 1-4:
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 1, id, 4900 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 5;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 2, id, 4300 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 6;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 3, id, 7800 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 9;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 4, id, 5800 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 11;

-- Цены для остальных (5-30):
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 5, id, 5100 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 5;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 6, id, 5300 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 5;

INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 7, id, 4600 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 6;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 8, id, 4800 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 6;

INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 9, id, 3800 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 7;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 10, id, 4200 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 7;

INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 11, id, 3300 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 8;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 12, id, 3700 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 8;

INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 13, id, 8100 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 9;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 14, id, 8300 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 9;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 15, id, 8500 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 9;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 16, id, 8800 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 9;

INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 17, id, 9500 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 10;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 18, id, 9800 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 10;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 19, id, 10200 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 10;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 20, id, 10500 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 10;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 21, id, 10800 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 10;

INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 22, id, 6100 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 11;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 23, id, 6300 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 11;

INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 24, id, 6300 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 12;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 25, id, 6600 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 12;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 26, id, 6800 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 12;

INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 27, id, 6800 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 13;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 28, id, 7200 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 13;

INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 29, id, 2800 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 14;
INSERT INTO product_parameter_value (product_id, characteristic_id, value_number)
SELECT 30, id, 3200 FROM enum_characteristic WHERE characteristic_name = 'Price' AND class_id = 14;

-- Обновляем последовательность
SELECT setval('product_id_seq', 30);