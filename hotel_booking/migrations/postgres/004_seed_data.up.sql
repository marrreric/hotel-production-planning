-- 004_seed_data.up.sql
-- Создание классификатора и 4 базовых номеров

-- Корень: Номера отеля
INSERT INTO classification_element (class_code, name, is_terminal, sort_order, parent_id) VALUES
('ROOMS', 'Номера отеля', false, 0, NULL);

-- Категории
INSERT INTO classification_element (class_code, name, is_terminal, sort_order, parent_id) VALUES
('STANDARD', 'Стандарт (до 2 человек)', false, 1, 1),
('LUXE', 'Люкс (до 2 человек)', false, 2, 1),
('APARTMENTS', 'Апартаменты (до 6 человек)', false, 3, 1);

-- Терминальные узлы — Стандарт
INSERT INTO classification_element (class_code, name, is_terminal, sort_order, unit_of_measure, parent_id) VALUES
('STD_FULL', 'WiFi + Завтрак + Горничная', true, 1, 'ночь', 2),
('STD_BF', 'WiFi + Завтрак', true, 2, 'ночь', 2),
('STD_HK', 'WiFi + Горничная', true, 3, 'ночь', 2),
('STD_WIFI', 'Только WiFi', true, 4, 'ночь', 2);

-- Терминальные узлы — Люкс
INSERT INTO classification_element (class_code, name, is_terminal, sort_order, unit_of_measure, parent_id) VALUES
('LUXE_FULL', 'Минибар + WiFi + Завтрак + Горничная', true, 1, 'ночь', 3),
('LUXE_ALL', 'Минибар + WiFi + Всё включено + Горничная', true, 2, 'ночь', 3);

-- Терминальные узлы — Апартаменты
INSERT INTO classification_element (class_code, name, is_terminal, sort_order, unit_of_measure, parent_id) VALUES
('APT_CLEAN', 'WiFi + Завтрак + Полная уборка', true, 1, 'ночь', 4),
('APT_KITCHEN', 'WiFi + Кухня + Горничная 2р/нед', true, 2, 'ночь', 4),
('APT_TRANSFER', 'WiFi + Трансфер + Завтрак', true, 3, 'ночь', 4),
('APT_NONE', 'Без услуг', true, 4, 'ночь', 4);

-- Создаём только 4 базовых номера (по одному на категорию)
-- id будут: 1, 2, 3, 4
INSERT INTO product (id, name, short_name, class_id) VALUES
(1, 'Стандарт 101', '101', 5),   -- STD_FULL
(2, 'Стандарт 102', '102', 6),   -- STD_BF
(3, 'Люкс 201',    '201', 9),   -- LUXE_FULL
(4, 'Апартаменты 301', '301', 11); -- APT_CLEAN