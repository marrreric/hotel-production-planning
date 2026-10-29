-- 013_add_modifications.up.sql
-- Добавление двух модификаций:
--   1. Люкс 201 Эконом (исключить минибар, заменить шампунь 50→30 мл)
--   2. Стандарт 101 Эконом (исключить завтрак)

DO $$
DECLARE
    -- Базовые изделия
    p_lux201 INTEGER;
    p_std101 INTEGER;
    
    -- Спецификации базовые
    s_lux201 INTEGER;
    s_std101 INTEGER;
    
    -- Компоненты для изменений
    p_minibar INTEGER;
    p_shampoo INTEGER;
    p_breakfast INTEGER;
    
    -- Единицы измерения
    u_ml INTEGER;
    
    -- Новые изделия-модификации
    p_lux201_econ INTEGER;
    p_std101_econ INTEGER;
    
    -- Новые спецификации-модификации
    s_lux201_econ INTEGER;
    s_std101_econ INTEGER;
    
    -- Извещение
    ch INTEGER;
BEGIN
    -- =====================================================
    -- 1. Получаем ID базовых изделий и их спецификаций
    -- =====================================================
    SELECT id INTO p_lux201 FROM product WHERE short_name = '201';
    SELECT id INTO p_std101 FROM product WHERE short_name = '101';
    
    SELECT id INTO s_lux201 FROM specification WHERE designation = 'СП-ЛЮКС-201';
    SELECT id INTO s_std101 FROM specification WHERE designation = 'СП-СТД-101';
    
    -- Проверки
    IF p_lux201 IS NULL THEN RAISE EXCEPTION 'Не найден Люкс 201'; END IF;
    IF p_std101 IS NULL THEN RAISE EXCEPTION 'Не найден Стандарт 101'; END IF;
    IF s_lux201 IS NULL THEN RAISE EXCEPTION 'Не найдена СП-ЛЮКС-201'; END IF;
    IF s_std101 IS NULL THEN RAISE EXCEPTION 'Не найдена СП-СТД-101'; END IF;
    
    -- =====================================================
    -- 2. Получаем ID компонентов для изменений
    -- =====================================================
    SELECT id INTO p_minibar FROM product WHERE short_name = 'MINIBAR';
    SELECT id INTO p_shampoo FROM product WHERE short_name = 'SHAMPOO';
    SELECT id INTO p_breakfast FROM product WHERE short_name = 'BREAKFAST';
    
    IF p_minibar IS NULL THEN RAISE EXCEPTION 'Не найден MINIBAR'; END IF;
    IF p_shampoo IS NULL THEN RAISE EXCEPTION 'Не найден SHAMPOO'; END IF;
    IF p_breakfast IS NULL THEN RAISE EXCEPTION 'Не найден BREAKFAST'; END IF;
    
    -- Единица измерения "мл"
    SELECT id INTO u_ml FROM unit_of_measure WHERE code = 'ML';
    IF u_ml IS NULL THEN RAISE EXCEPTION 'Не найдена единица ML'; END IF;
    
    -- =====================================================
    -- 3. Создаём извещение ИИ-002 (уже проведено)
    -- =====================================================
    ch := bom_create_change('ИИ-002', DATE '2026-11-01',
                             'Создание модификаций: Люкс 201 Эконом, Стандарт 101 Эконом');
    
    -- =====================================================
    -- 4. Создаём изделие-модификацию "Люкс 201 Эконом"
    -- =====================================================
    INSERT INTO product (name, short_name, class_id, base_product_id, is_modification)
    SELECT 'Люкс 201 Эконом', '201-Э', class_id, id, TRUE
    FROM product WHERE id = p_lux201
    RETURNING id INTO p_lux201_econ;
    
    -- Создаём спецификацию-модификацию
    INSERT INTO specification (product_id, designation, spec_type, base_spec_id, status, description)
    VALUES (p_lux201_econ, 'СП-ЛЮКС-201-Э', 'Модификация', s_lux201, 'Действует',
            'Эконом-вариант: без минибара, шампунь 30 мл')
    RETURNING id INTO s_lux201_econ;
    
    -- Строка 1: ИСКЛЮЧИТЬ минибар
    INSERT INTO specification_line (
        spec_id, position, action, excluded_component_id,
        date_from, notice_from_id
    ) VALUES (
        s_lux201_econ, 1, 'Исключить', p_minibar,
        DATE '2026-11-01', ch
    );
    
    -- Строка 2: ЗАМЕНИТЬ шампунь (50 → 30 мл)
    INSERT INTO specification_line (
        spec_id, position, action, excluded_component_id, component_id,
        quantity, ei_id, date_from, notice_from_id
    ) VALUES (
        s_lux201_econ, 2, 'Заменить', p_shampoo, p_shampoo,
        30, u_ml, DATE '2026-11-01', ch
    );
    
    -- =====================================================
    -- 5. Создаём изделие-модификацию "Стандарт 101 Эконом"
    -- =====================================================
    INSERT INTO product (name, short_name, class_id, base_product_id, is_modification)
    SELECT 'Стандарт 101 Эконом', '101-Э', class_id, id, TRUE
    FROM product WHERE id = p_std101
    RETURNING id INTO p_std101_econ;
    
    -- Создаём спецификацию-модификацию
    INSERT INTO specification (product_id, designation, spec_type, base_spec_id, status, description)
    VALUES (p_std101_econ, 'СП-СТД-101-Э', 'Модификация', s_std101, 'Действует',
            'Эконом-вариант: без завтрака')
    RETURNING id INTO s_std101_econ;
    
    -- Строка 1: ИСКЛЮЧИТЬ завтрак
    INSERT INTO specification_line (
        spec_id, position, action, excluded_component_id,
        date_from, notice_from_id
    ) VALUES (
        s_std101_econ, 1, 'Исключить', p_breakfast,
        DATE '2026-11-01', ch
    );
    
    -- =====================================================
    -- 6. Проводим извещение (нельзя больше менять)
    -- =====================================================
    PERFORM bom_close_change(ch);
    
    RAISE NOTICE 'Созданы модификации: Люкс 201 Эконом (id=%), Стандарт 101 Эконом (id=%)',
        p_lux201_econ, p_std101_econ;
    RAISE NOTICE 'Спецификации: СП-ЛЮКС-201-Э (id=%), СП-СТД-101-Э (id=%)',
        s_lux201_econ, s_std101_econ;
END;
$$;