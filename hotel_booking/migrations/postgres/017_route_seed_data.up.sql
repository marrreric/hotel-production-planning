-- 017_route_seed_data.up.sql
-- Лаба 6. Тестовые данные: справочники, маршрут завтрака, типовой ТП подготовки номера

DO $$
DECLARE
    -- ветки классификатора
    c_ops INTEGER; c_profs INTEGER;
    op_linen INTEGER; op_clean INTEGER; op_check INTEGER; op_cook INTEGER; op_serve INTEGER;
    pr_maid INTEGER; pr_super INTEGER; pr_cook INTEGER; pr_waiter INTEGER;

    -- подразделения и ГРЦ
    d_house INTEGER; d_rest INTEGER;
    wc_rooms INTEGER; wc_kitchen INTEGER; wc_hall INTEGER;

    -- единицы измерения
    u_kg INTEGER; u_ml INTEGER; u_g INTEGER; u_l INTEGER; u_pair INTEGER;

    -- изделия из лаб 4-5
    p_breakfast INTEGER; p_food INTEGER; p_shampoo INTEGER; p_soap INTEGER;
    p_slippers INTEGER; p_detergent INTEGER;
    p_std101 INTEGER; p_lux201 INTEGER; p_apt301 INTEGER;

    -- операции завтрака
    o_food INTEGER; o_cook INTEGER; o_serve INTEGER;

    -- типовой ТП
    tp INTEGER; par_area INTEGER; par_guests INTEGER;
    t10 INTEGER; t20 INTEGER; t30 INTEGER; t40 INTEGER;
BEGIN
    SELECT id INTO u_kg   FROM unit_of_measure WHERE code = 'KG';
    SELECT id INTO u_ml   FROM unit_of_measure WHERE code = 'ML';
    SELECT id INTO u_g    FROM unit_of_measure WHERE code = 'G';
    SELECT id INTO u_l    FROM unit_of_measure WHERE code = 'L';
    SELECT id INTO u_pair FROM unit_of_measure WHERE code = 'PAIR';

    SELECT id INTO p_breakfast FROM product WHERE short_name = 'BREAKFAST';
    SELECT id INTO p_food      FROM product WHERE short_name = 'FOOD';
    SELECT id INTO p_shampoo   FROM product WHERE short_name = 'SHAMPOO';
    SELECT id INTO p_soap      FROM product WHERE short_name = 'SOAP';
    SELECT id INTO p_slippers  FROM product WHERE short_name = 'SLIPPERS';
    SELECT id INTO p_detergent FROM product WHERE short_name = 'DETERGENT';
    SELECT id INTO p_std101    FROM product WHERE short_name = '101';
    SELECT id INTO p_lux201    FROM product WHERE short_name = '201';
    SELECT id INTO p_apt301    FROM product WHERE short_name = '301';

    -- =====================================================
    -- 1. КЛАССИФИКАТОР ТЕХ. ОПЕРАЦИЙ И ПРОФЕССИЙ
    -- =====================================================
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order)
    VALUES ('TECH_OPS', 'Технологические операции', false, 3) RETURNING id INTO c_ops;
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('OP_LINEN', 'Смена белья', true, 1, c_ops) RETURNING id INTO op_linen;
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('OP_CLEAN', 'Уборка', true, 2, c_ops) RETURNING id INTO op_clean;
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('OP_CHECK', 'Контроль', true, 3, c_ops) RETURNING id INTO op_check;
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('OP_COOK', 'Приготовление пищи', true, 4, c_ops) RETURNING id INTO op_cook;
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('OP_SERVE', 'Обслуживание гостей', true, 5, c_ops) RETURNING id INTO op_serve;

    INSERT INTO classification_element(class_code, name, is_terminal, sort_order)
    VALUES ('PROFESSIONS', 'Профессии', false, 4) RETURNING id INTO c_profs;
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('PRF_MAID', 'Горничная', true, 1, c_profs) RETURNING id INTO pr_maid;
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('PRF_SUPERVISOR', 'Супервайзер', true, 2, c_profs) RETURNING id INTO pr_super;
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('PRF_COOK', 'Повар', true, 3, c_profs) RETURNING id INTO pr_cook;
    INSERT INTO classification_element(class_code, name, is_terminal, sort_order, parent_id)
    VALUES ('PRF_WAITER', 'Официант', true, 4, c_profs) RETURNING id INTO pr_waiter;

    -- часовые ставки, руб/ч
    INSERT INTO profession_rate(profession_id, hourly_rate) VALUES
        (pr_maid, 350), (pr_super, 500), (pr_cook, 450), (pr_waiter, 300);

    -- =====================================================
    -- 2. ПОДРАЗДЕЛЕНИЯ И ГРЦ
    -- =====================================================
    INSERT INTO department(name) VALUES ('Хозяйственная служба') RETURNING id INTO d_house;
    INSERT INTO department(name) VALUES ('Ресторан') RETURNING id INTO d_rest;

    INSERT INTO work_center(name, department_id) VALUES ('Служба номерного фонда', d_house)
        RETURNING id INTO wc_rooms;
    INSERT INTO work_center(name, department_id) VALUES ('Кухня', d_rest)
        RETURNING id INTO wc_kitchen;
    INSERT INTO work_center(name, department_id) VALUES ('Зал ресторана', d_rest)
        RETURNING id INTO wc_hall;

    -- =====================================================
    -- 3. ПОЗИЦИИ ЗАКУПКИ (цена за единицу)
    -- =====================================================
    INSERT INTO route_operation(product_id, kind, ei_id, unit_price) VALUES
        (p_food,      'Закупка', u_kg,   450),
        (p_shampoo,   'Закупка', u_ml,   0.8),
        (p_soap,      'Закупка', u_g,    0.5),
        (p_slippers,  'Закупка', u_pair, 60),
        (p_detergent, 'Закупка', u_l,    200);
    SELECT id INTO o_food FROM route_operation WHERE product_id = p_food AND kind = 'Закупка';

    -- =====================================================
    -- 4. МАРШРУТ ЗАВТРАКА (создан вручную)
    -- =====================================================
    INSERT INTO route_operation(product_id, kind, num, name, op_class_id, work_center_id,
                                profession_id, qualification, t_pz, t_sht)
    VALUES (p_breakfast, 'Операция', 10, 'Приготовление завтрака', op_cook, wc_kitchen,
            pr_cook, 4, 20, 12)
    RETURNING id INTO o_cook;
    INSERT INTO route_operation(product_id, kind, num, name, op_class_id, work_center_id,
                                profession_id, qualification, t_pz, t_sht)
    VALUES (p_breakfast, 'Операция', 20, 'Подача завтрака', op_serve, wc_hall,
            pr_waiter, 3, 5, 5)
    RETURNING id INTO o_serve;

    INSERT INTO route_input(out_op_id, in_op_id, qty, for_qty) VALUES
        (o_cook,  o_food, 0.3, 1),   -- 0.3 кг продуктов на 1 порцию
        (o_serve, o_cook, 1,   1);   -- подаём приготовленный завтрак

    -- =====================================================
    -- 5. ТИПОВОЙ ТП ПОДГОТОВКИ НОМЕРА
    -- =====================================================
    INSERT INTO typical_process(name, description)
    VALUES ('Типовая подготовка номера',
            'Подготовка номера к заселению на сутки. Нормы зависят от площади и числа гостей')
    RETURNING id INTO tp;

    INSERT INTO typical_process_param(tp_id, code, name, unit)
    VALUES (tp, 'AREA', 'Площадь номера', 'м²') RETURNING id INTO par_area;
    INSERT INTO typical_process_param(tp_id, code, name, unit)
    VALUES (tp, 'GUESTS', 'Число гостей', 'чел') RETURNING id INTO par_guests;

    -- Тшт = t_sht_base + t_sht_k * параметр
    INSERT INTO typical_process_op(tp_id, num, name, op_class_id, work_center_id, profession_id,
                                   qualification, t_pz, t_sht_base, t_sht_k, t_sht_param_id)
    VALUES (tp, 10, 'Сбор белья и мусора', op_linen, wc_rooms, pr_maid, 2, 5, 5, 0, NULL)
    RETURNING id INTO t10;
    INSERT INTO typical_process_op(tp_id, num, name, op_class_id, work_center_id, profession_id,
                                   qualification, t_pz, t_sht_base, t_sht_k, t_sht_param_id)
    VALUES (tp, 20, 'Влажная уборка', op_clean, wc_rooms, pr_maid, 2, 5, 5, 0.5, par_area)
    RETURNING id INTO t20;
    INSERT INTO typical_process_op(tp_id, num, name, op_class_id, work_center_id, profession_id,
                                   qualification, t_pz, t_sht_base, t_sht_k, t_sht_param_id)
    VALUES (tp, 30, 'Застилка и выкладка косметики', op_linen, wc_rooms, pr_maid, 2, 0, 3, 4, par_guests)
    RETURNING id INTO t30;
    INSERT INTO typical_process_op(tp_id, num, name, op_class_id, work_center_id, profession_id,
                                   qualification, t_pz, t_sht_base, t_sht_k, t_sht_param_id)
    VALUES (tp, 40, 'Приёмка номера и заказ завтрака', op_check, wc_rooms, pr_super, 4, 0, 5, 0, NULL)
    RETURNING id INTO t40;

    -- расход = qty_base + qty_k * параметр
    INSERT INTO typical_process_input(tp_op_id, material_id, qty_base, qty_k, qty_param_id) VALUES
        (t20, p_detergent, 0, 0.002, par_area),   -- 2 мл моющего на 1 м²
        (t30, p_shampoo,   0, 30,    par_guests), -- 30 мл шампуня на гостя
        (t30, p_soap,      0, 20,    par_guests), -- 20 г мыла на гостя
        (t30, p_slippers,  0, 1,     par_guests), -- пара тапочек на гостя
        (t40, p_breakfast, 0, 1,     par_guests); -- завтрак на гостя (вложенный маршрут)

    -- =====================================================
    -- 6. ПАРАМЕТРЫ НОМЕРОВ И ПРИМЕНЕНИЕ ТИПОВОГО ТП
    -- =====================================================
    INSERT INTO product_tp_value(product_id, param_id, value) VALUES
        (p_std101, par_area, 25), (p_std101, par_guests, 2),
        (p_lux201, par_area, 40), (p_lux201, par_guests, 2),
        (p_apt301, par_area, 50), (p_apt301, par_guests, 4);

    PERFORM apply_typical_process(p_std101, tp);
    PERFORM apply_typical_process(p_lux201, tp);
    PERFORM apply_typical_process(p_apt301, tp);

    RAISE NOTICE 'Данные маршрутной технологии загружены';
END;
$$;
