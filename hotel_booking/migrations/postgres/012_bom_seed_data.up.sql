-- 012_bom_seed_data.up.sql
-- BOM-данные: 4 спецификации для 4 категорий номеров

DO $$
DECLARE
    -- Классы
    c_services INTEGER;
    c_consumables INTEGER;
    c_staff INTEGER;
    
    -- Единицы измерения
    u_pcs INTEGER; u_kg INTEGER; u_g INTEGER;
    u_l INTEGER; u_ml INTEGER;
    u_min INTEGER; u_set INTEGER; u_pair INTEGER; u_portion INTEGER;
    
    -- Существующие номера (НЕ создаём новые!)
    p_std101 INTEGER;   -- id=1
    p_lux201 INTEGER;   -- id=3
    p_pres206 INTEGER;  -- id=17
    p_apt301 INTEGER;   -- id=4
    
    -- Компоненты BOM
    p_breakfast INTEGER; p_cleaning INTEGER; p_minibar INTEGER; p_wifi INTEGER;
    p_towel INTEGER; p_shampoo INTEGER; p_soap INTEGER;
    p_slippers INTEGER; p_bed INTEGER; p_food INTEGER; p_detergent INTEGER;
    p_cook INTEGER; p_maid INTEGER;
    
    -- Спецификации
    s_std INTEGER; s_lux INTEGER; s_pres INTEGER; s_apt INTEGER;
    s_breakfast INTEGER; s_cleaning INTEGER;
    ch0 INTEGER;
BEGIN
    -- Получаем единицы измерения
    SELECT id INTO u_pcs     FROM unit_of_measure WHERE code = 'PCS';
    SELECT id INTO u_kg      FROM unit_of_measure WHERE code = 'KG';
    SELECT id INTO u_g       FROM unit_of_measure WHERE code = 'G';
    SELECT id INTO u_l       FROM unit_of_measure WHERE code = 'L';
    SELECT id INTO u_ml      FROM unit_of_measure WHERE code = 'ML';
    SELECT id INTO u_min     FROM unit_of_measure WHERE code = 'MIN';
    SELECT id INTO u_set     FROM unit_of_measure WHERE code = 'SET';
    SELECT id INTO u_pair    FROM unit_of_measure WHERE code = 'PAIR';
    SELECT id INTO u_portion FROM unit_of_measure WHERE code = 'PORTION';

    -- =====================================================
    -- 1. СОЗДАЁМ КЛАССЫ УСЛУГ И РЕСУРСОВ
    -- =====================================================
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('SERVICE_TREE', 'Услуги и ресурсы отеля', false, 20, NULL);
    
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('SERVICES_LIST', 'Услуги', false, 1, 
            (SELECT id FROM classification_element WHERE class_code = 'SERVICE_TREE'));
    
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('CONSUMABLES', 'Расходные материалы', false, 2,
            (SELECT id FROM classification_element WHERE class_code = 'SERVICE_TREE'));
    
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('STAFF', 'Трудозатраты', false, 3,
            (SELECT id FROM classification_element WHERE class_code = 'SERVICE_TREE'));
    
    -- Терминальные классы
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('SRV_BREAKFAST', 'Завтрак', true, 'порц', 
            (SELECT id FROM classification_element WHERE class_code = 'SERVICES_LIST'));
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('SRV_CLEANING', 'Уборка', true, 'раз',
            (SELECT id FROM classification_element WHERE class_code = 'SERVICES_LIST'));
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('SRV_WIFI', 'WiFi', true, 'подключение',
            (SELECT id FROM classification_element WHERE class_code = 'SERVICES_LIST'));
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('SRV_MINIBAR', 'Минибар', true, 'компл',
            (SELECT id FROM classification_element WHERE class_code = 'SERVICES_LIST'));
    
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('CNS_TOWEL', 'Полотенце', true, 'шт',
            (SELECT id FROM classification_element WHERE class_code = 'CONSUMABLES'));
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('CNS_SHAMPOO', 'Шампунь', true, 'мл',
            (SELECT id FROM classification_element WHERE class_code = 'CONSUMABLES'));
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('CNS_SOAP', 'Мыло', true, 'г',
            (SELECT id FROM classification_element WHERE class_code = 'CONSUMABLES'));
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('CNS_SLIPPERS', 'Тапочки', true, 'пара',
            (SELECT id FROM classification_element WHERE class_code = 'CONSUMABLES'));
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('CNS_BED_LINEN', 'Постельное бельё', true, 'компл',
            (SELECT id FROM classification_element WHERE class_code = 'CONSUMABLES'));
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('CNS_FOOD', 'Продукты', true, 'кг',
            (SELECT id FROM classification_element WHERE class_code = 'CONSUMABLES'));
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('CNS_DETERGENT', 'Моющее средство', true, 'л',
            (SELECT id FROM classification_element WHERE class_code = 'CONSUMABLES'));
    
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('STF_MAID', 'Труд горничной', true, 'мин',
            (SELECT id FROM classification_element WHERE class_code = 'STAFF'));
    INSERT INTO classification_element(class_code, name, is_terminal, unit_of_measure, parent_id)
    VALUES ('STF_COOK', 'Труд повара', true, 'мин',
            (SELECT id FROM classification_element WHERE class_code = 'STAFF'));

    -- =====================================================
    -- 2. СОЗДАЁМ ИЗДЕЛИЯ-КОМПОНЕНТЫ (только они — новые!)
    -- =====================================================
    INSERT INTO product(name, short_name, class_id) VALUES ('Завтрак', 'BREAKFAST',
        (SELECT id FROM classification_element WHERE class_code = 'SRV_BREAKFAST')) RETURNING id INTO p_breakfast;
    INSERT INTO product(name, short_name, class_id) VALUES ('Уборка номера', 'CLEANING',
        (SELECT id FROM classification_element WHERE class_code = 'SRV_CLEANING')) RETURNING id INTO p_cleaning;
    INSERT INTO product(name, short_name, class_id) VALUES ('Минибар', 'MINIBAR',
        (SELECT id FROM classification_element WHERE class_code = 'SRV_MINIBAR')) RETURNING id INTO p_minibar;
    INSERT INTO product(name, short_name, class_id) VALUES ('WiFi', 'WIFI',
        (SELECT id FROM classification_element WHERE class_code = 'SRV_WIFI')) RETURNING id INTO p_wifi;
    
    INSERT INTO product(name, short_name, class_id) VALUES ('Полотенце банное', 'TOWEL',
        (SELECT id FROM classification_element WHERE class_code = 'CNS_TOWEL')) RETURNING id INTO p_towel;
    INSERT INTO product(name, short_name, class_id) VALUES ('Шампунь', 'SHAMPOO',
        (SELECT id FROM classification_element WHERE class_code = 'CNS_SHAMPOO')) RETURNING id INTO p_shampoo;
    INSERT INTO product(name, short_name, class_id) VALUES ('Мыло', 'SOAP',
        (SELECT id FROM classification_element WHERE class_code = 'CNS_SOAP')) RETURNING id INTO p_soap;
    INSERT INTO product(name, short_name, class_id) VALUES ('Тапочки', 'SLIPPERS',
        (SELECT id FROM classification_element WHERE class_code = 'CNS_SLIPPERS')) RETURNING id INTO p_slippers;
    INSERT INTO product(name, short_name, class_id) VALUES ('Постельное бельё', 'BED_LINEN',
        (SELECT id FROM classification_element WHERE class_code = 'CNS_BED_LINEN')) RETURNING id INTO p_bed;
    INSERT INTO product(name, short_name, class_id) VALUES ('Продукты для завтрака', 'FOOD',
        (SELECT id FROM classification_element WHERE class_code = 'CNS_FOOD')) RETURNING id INTO p_food;
    INSERT INTO product(name, short_name, class_id) VALUES ('Моющее средство', 'DETERGENT',
        (SELECT id FROM classification_element WHERE class_code = 'CNS_DETERGENT')) RETURNING id INTO p_detergent;
    
    INSERT INTO product(name, short_name, class_id) VALUES ('Труд повара', 'COOK',
        (SELECT id FROM classification_element WHERE class_code = 'STF_COOK')) RETURNING id INTO p_cook;
    INSERT INTO product(name, short_name, class_id) VALUES ('Труд горничной', 'MAID',
        (SELECT id FROM classification_element WHERE class_code = 'STF_MAID')) RETURNING id INTO p_maid;

    -- =====================================================
    -- 3. НАХОДИМ ID СУЩЕСТВУЮЩИХ НОМЕРОВ (НЕ создаём их!)
    -- =====================================================
    SELECT id INTO p_std101  FROM product WHERE short_name = '101';
    SELECT id INTO p_lux201  FROM product WHERE short_name = '201';
    SELECT id INTO p_pres206 FROM product WHERE short_name = '206';
    SELECT id INTO p_apt301  FROM product WHERE short_name = '301';
    
    -- Проверяем, что все номера найдены
    IF p_std101 IS NULL THEN RAISE EXCEPTION 'Не найден номер 101'; END IF;
    IF p_lux201 IS NULL THEN RAISE EXCEPTION 'Не найден номер 201'; END IF;
    IF p_pres206 IS NULL THEN RAISE EXCEPTION 'Не найден номер 206'; END IF;
    IF p_apt301 IS NULL THEN RAISE EXCEPTION 'Не найден номер 301'; END IF;

    -- =====================================================
    -- 4. СОЗДАЁМ ИЗВЕЩЕНИЕ
    -- =====================================================
    ch0 := bom_create_change('ИИ-000', DATE '2026-01-01', 
                              'Первичное создание спецификаций для 4 категорий номеров');

    -- =====================================================
    -- 5. СПЕЦИФИКАЦИИ ДЛЯ ПОЛУФАБРИКАТОВ
    -- =====================================================
    s_breakfast := bom_create_base(p_breakfast, 'СП-ЗАВТРАК', 'Завтрак, норма на 1 порцию');
    PERFORM bom_add_line(s_breakfast, p_food, 0.3, u_kg, ch0, 1);
    PERFORM bom_add_line(s_breakfast, p_cook, 15, u_min, ch0, 2);
    
    s_cleaning := bom_create_base(p_cleaning, 'СП-УБОРКА', 'Уборка, норма на 1 раз');
    PERFORM bom_add_line(s_cleaning, p_maid, 25, u_min, ch0, 1);
    PERFORM bom_add_line(s_cleaning, p_detergent, 0.05, u_l, ch0, 2);

    -- =====================================================
    -- 6. СПЕЦИФИКАЦИЯ "СТАНДАРТ 101" (STD_FULL)
    -- =====================================================
    s_std := bom_create_base(p_std101, 'СП-СТД-101', 
                              'Стандарт 101: WiFi + Завтрак + Горничная');
    PERFORM bom_add_line(s_std, p_breakfast, 1, u_portion, ch0, 1);
    PERFORM bom_add_line(s_std, p_wifi,      1, u_pcs,     ch0, 2);
    PERFORM bom_add_line(s_std, p_towel,     2, u_pcs,     ch0, 3);
    PERFORM bom_add_line(s_std, p_shampoo,  30, u_ml,      ch0, 4);
    PERFORM bom_add_line(s_std, p_soap,     20, u_g,       ch0, 5);
    PERFORM bom_add_line(s_std, p_bed,       1, u_set,     ch0, 6);

    -- =====================================================
    -- 7. СПЕЦИФИКАЦИЯ "ЛЮКС 201" (LUXE_FULL)
    -- =====================================================
    s_lux := bom_create_base(p_lux201, 'СП-ЛЮКС-201', 
                              'Люкс 201: Минибар + WiFi + Завтрак + Горничная');
    PERFORM bom_add_line(s_lux, p_breakfast, 1, u_portion, ch0, 1);
    PERFORM bom_add_line(s_lux, p_cleaning,  1, u_pcs,     ch0, 2);
    PERFORM bom_add_line(s_lux, p_wifi,      1, u_pcs,     ch0, 3);
    PERFORM bom_add_line(s_lux, p_minibar,   1, u_set,     ch0, 4);
    PERFORM bom_add_line(s_lux, p_towel,     3, u_pcs,     ch0, 5);
    PERFORM bom_add_line(s_lux, p_shampoo,  50, u_ml,      ch0, 6);
    PERFORM bom_add_line(s_lux, p_soap,     30, u_g,       ch0, 7);
    PERFORM bom_add_line(s_lux, p_slippers,  1, u_pair,    ch0, 8);
    PERFORM bom_add_line(s_lux, p_bed,       1, u_set,     ch0, 9);

    -- =====================================================
    -- 8. СПЕЦИФИКАЦИЯ "ПРЕЗИДЕНТСКИЙ 206" (LUXE_ALL)
    -- =====================================================
    s_pres := bom_create_base(p_pres206, 'СП-ПРЕЗ-206', 
                               'Президентский 206: Минибар + WiFi + Всё включено + Горничная');
    PERFORM bom_add_line(s_pres, p_breakfast, 1, u_portion, ch0, 1);
    PERFORM bom_add_line(s_pres, p_cleaning,  2, u_pcs,     ch0, 2);
    PERFORM bom_add_line(s_pres, p_wifi,      1, u_pcs,     ch0, 3);
    PERFORM bom_add_line(s_pres, p_minibar,   1, u_set,     ch0, 4);
    PERFORM bom_add_line(s_pres, p_towel,     4, u_pcs,     ch0, 5);
    PERFORM bom_add_line(s_pres, p_shampoo,  70, u_ml,      ch0, 6);
    PERFORM bom_add_line(s_pres, p_soap,     40, u_g,       ch0, 7);
    PERFORM bom_add_line(s_pres, p_slippers,  2, u_pair,    ch0, 8);
    PERFORM bom_add_line(s_pres, p_bed,       2, u_set,     ch0, 9);

    -- =====================================================
    -- 9. СПЕЦИФИКАЦИЯ "АПАРТАМЕНТЫ 301" (APT_CLEAN)
    -- =====================================================
    s_apt := bom_create_base(p_apt301, 'СП-АПТ-301', 
                              'Апартаменты 301: WiFi + Завтрак + Полная уборка');
    PERFORM bom_add_line(s_apt, p_breakfast, 2, u_portion, ch0, 1);
    PERFORM bom_add_line(s_apt, p_cleaning,  1, u_pcs,     ch0, 2);
    PERFORM bom_add_line(s_apt, p_wifi,      1, u_pcs,     ch0, 3);
    PERFORM bom_add_line(s_apt, p_towel,     4, u_pcs,     ch0, 4);
    PERFORM bom_add_line(s_apt, p_shampoo,  60, u_ml,      ch0, 5);
    PERFORM bom_add_line(s_apt, p_soap,     40, u_g,       ch0, 6);
    PERFORM bom_add_line(s_apt, p_slippers,  2, u_pair,    ch0, 7);
    PERFORM bom_add_line(s_apt, p_bed,       2, u_set,     ch0, 8);

    PERFORM bom_close_change(ch0);
    RAISE NOTICE 'BOM данные для 4 категорий загружены';
END;
$$;