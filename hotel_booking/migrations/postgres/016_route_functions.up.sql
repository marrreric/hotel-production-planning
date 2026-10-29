-- 016_route_functions.up.sql
-- Лаба 6. Маршрутная технология: функции

-- Выходная операция изделия: последняя операция маршрута,
-- а если маршрута нет (покупное изделие) - позиция закупки
CREATE OR REPLACE FUNCTION route_output_op(p_product INTEGER)
RETURNS INTEGER LANGUAGE sql STABLE AS $$
    SELECT id FROM route_operation
    WHERE product_id = p_product
    ORDER BY (kind = 'Операция') DESC, num DESC NULLS LAST
    LIMIT 1;
$$;

-- FIND_TM: весь тех. маршрут изделия на всю глубину вложенности.
-- Идём от выходной операции назад по входным ресурсам.
-- qty_per_product - сколько единиц результата строки нужно на 1 изделие
CREATE OR REPLACE FUNCTION find_tm(p_product INTEGER)
RETURNS TABLE (
    level INTEGER,
    op_id INTEGER,
    parent_op_id INTEGER,
    product_id INTEGER,
    product_name TEXT,
    kind TEXT,
    num INTEGER,
    op_name TEXT,
    op_class TEXT,
    work_center TEXT,
    profession TEXT,
    qualification INTEGER,
    t_pz NUMERIC,
    t_sht NUMERIC,
    qty_per_product NUMERIC,
    unit_name TEXT,
    path INTEGER[]
) LANGUAGE sql STABLE AS $$
    WITH RECURSIVE t (lvl, op, parent, q, path) AS (
        SELECT 1, route_output_op(p_product), NULL::INTEGER, 1::NUMERIC,
               ARRAY[route_output_op(p_product)]
        WHERE route_output_op(p_product) IS NOT NULL
        UNION ALL
        SELECT t.lvl + 1, ri.in_op_id, t.op, t.q * ri.qty / ri.for_qty,
               t.path || ri.in_op_id
        FROM t
        JOIN route_input ri ON ri.out_op_id = t.op
        WHERE t.lvl < 50
          AND NOT (ri.in_op_id = ANY (t.path))  -- защита от циклов
    )
    SELECT t.lvl, t.op, t.parent, ro.product_id, p.name::TEXT, ro.kind::TEXT,
           ro.num, ro.name::TEXT, oc.name::TEXT, wc.name::TEXT, pr.name::TEXT,
           ro.qualification, ro.t_pz, ro.t_sht, ROUND(t.q, 6), u.short_name::TEXT, t.path
    FROM t
    JOIN route_operation ro ON ro.id = t.op
    JOIN product p ON p.id = ro.product_id
    LEFT JOIN classification_element oc ON oc.id = ro.op_class_id
    LEFT JOIN work_center wc ON wc.id = ro.work_center_id
    LEFT JOIN classification_element pr ON pr.id = ro.profession_id
    LEFT JOIN unit_of_measure u ON u.id = ro.ei_id
    ORDER BY t.path;
$$;

-- MR_Q: нормы расхода материалов для одной операции на p_q единиц результата
CREATE OR REPLACE FUNCTION mr_q(p_op INTEGER, p_q DOUBLE PRECISION DEFAULT 1)
RETURNS TABLE (
    material_id INTEGER,
    material_name TEXT,
    norm NUMERIC,
    unit_name TEXT,
    unit_price NUMERIC,
    cost NUMERIC
) LANGUAGE sql STABLE AS $$
    SELECT ro.product_id, p.name::TEXT,
           ROUND(ri.qty / ri.for_qty * p_q::NUMERIC, 6),
           u.short_name::TEXT, ro.unit_price,
           ROUND(ri.qty / ri.for_qty * p_q::NUMERIC * ro.unit_price, 2)
    FROM route_input ri
    JOIN route_operation ro ON ro.id = ri.in_op_id AND ro.kind = 'Закупка'
    JOIN product p ON p.id = ro.product_id
    JOIN unit_of_measure u ON u.id = ro.ei_id
    WHERE ri.out_op_id = p_op
    ORDER BY p.name;
$$;

-- SUM_MR: сводные нормы материалов на p_q изделий (по всей глубине маршрута)
CREATE OR REPLACE FUNCTION sum_mr(p_product INTEGER, p_q DOUBLE PRECISION DEFAULT 1)
RETURNS TABLE (
    material_id INTEGER,
    material_name TEXT,
    total_norm NUMERIC,
    unit_name TEXT,
    unit_price NUMERIC,
    cost NUMERIC
) LANGUAGE sql STABLE AS $$
    SELECT f.product_id, f.product_name,
           ROUND(SUM(f.qty_per_product) * p_q::NUMERIC, 6),
           f.unit_name, ro.unit_price,
           ROUND(SUM(f.qty_per_product) * p_q::NUMERIC * ro.unit_price, 2)
    FROM find_tm(p_product) f
    JOIN route_operation ro ON ro.id = f.op_id
    WHERE f.kind = 'Закупка'
    GROUP BY f.product_id, f.product_name, f.unit_name, ro.unit_price
    ORDER BY f.product_name;
$$;

-- TR_TO: сводная трудоемкость на p_q изделий по профессиям и разрядам.
-- Время операции = Тпз + Тшт * количество
CREATE OR REPLACE FUNCTION tr_to(p_product INTEGER, p_q DOUBLE PRECISION DEFAULT 1)
RETURNS TABLE (
    profession_id INTEGER,
    profession TEXT,
    qualification INTEGER,
    total_min NUMERIC,
    total_hours NUMERIC,
    hourly_rate NUMERIC,
    cost NUMERIC
) LANGUAGE sql STABLE AS $$
    WITH ops AS (
        SELECT ro.profession_id AS prof_id, f.profession AS prof, f.qualification AS kval,
               f.t_pz + f.t_sht * f.qty_per_product * p_q::NUMERIC AS minutes
        FROM find_tm(p_product) f
        JOIN route_operation ro ON ro.id = f.op_id
        WHERE f.kind = 'Операция'
    )
    SELECT ops.prof_id, ops.prof, ops.kval,
           ROUND(SUM(ops.minutes), 2),
           ROUND(SUM(ops.minutes) / 60, 4),
           r.hourly_rate,
           ROUND(SUM(ops.minutes) / 60 * r.hourly_rate, 2)
    FROM ops
    LEFT JOIN profession_rate r ON r.profession_id = ops.prof_id
    GROUP BY ops.prof_id, ops.prof, ops.kval, r.hourly_rate
    ORDER BY ops.prof, ops.kval;
$$;

-- Калькуляция себестоимости p_q изделий: материалы + труд
CREATE OR REPLACE FUNCTION calc_cost(p_product INTEGER, p_q DOUBLE PRECISION DEFAULT 1)
RETURNS TABLE (
    material_cost NUMERIC,
    labor_cost NUMERIC,
    total_cost NUMERIC
) LANGUAGE sql STABLE AS $$
    SELECT m.v, l.v, m.v + l.v
    FROM (SELECT COALESCE(SUM(s.cost), 0) AS v FROM sum_mr(p_product, p_q) s) m,
         (SELECT COALESCE(SUM(t.cost), 0) AS v FROM tr_to(p_product, p_q) t) l;
$$;

-- Значение параметра типового ТП для изделия (0, если параметр не указан)
CREATE OR REPLACE FUNCTION tp_param_value(p_product INTEGER, p_param INTEGER)
RETURNS NUMERIC LANGUAGE sql STABLE AS $$
    SELECT COALESCE(
        (SELECT value FROM product_tp_value
         WHERE product_id = p_product AND param_id = p_param), 0);
$$;

-- Применение типового ТП к изделию: строит маршрут по шаблону,
-- подставляя значения параметров изделия в формулы Тшт и норм расхода.
-- Возвращает число созданных операций
CREATE OR REPLACE FUNCTION apply_typical_process(p_product INTEGER, p_tp INTEGER)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE
    op RECORD;
    inp RECORD;
    v_missing TEXT;
    v_new INTEGER;
    v_prev INTEGER := NULL;
    v_in_op INTEGER;
    v_qty NUMERIC;
    v_count INTEGER := 0;
BEGIN
    -- все параметры типового ТП должны быть заданы для изделия
    SELECT string_agg(pp.name, ', ') INTO v_missing
    FROM typical_process_param pp
    WHERE pp.tp_id = p_tp
      AND NOT EXISTS (SELECT 1 FROM product_tp_value v
                      WHERE v.product_id = p_product AND v.param_id = pp.id);
    IF v_missing IS NOT NULL THEN
        RAISE EXCEPTION 'Не заданы параметры: %', v_missing;
    END IF;

    -- маршрут, созданный вручную, не трогаем
    IF EXISTS (SELECT 1 FROM route_operation
               WHERE product_id = p_product AND kind = 'Операция' AND tp_id IS NULL) THEN
        RAISE EXCEPTION 'У изделия % уже есть маршрут, созданный вручную', p_product;
    END IF;

    -- старый маршрут из типового ТП удаляем (повторное применение после смены параметров)
    DELETE FROM route_operation WHERE product_id = p_product AND tp_id IS NOT NULL;

    FOR op IN SELECT * FROM typical_process_op WHERE tp_id = p_tp ORDER BY num LOOP
        INSERT INTO route_operation(product_id, kind, num, name, op_class_id, work_center_id,
                                    profession_id, qualification, t_pz, t_sht, tp_id)
        VALUES (p_product, 'Операция', op.num, op.name, op.op_class_id, op.work_center_id,
                op.profession_id, op.qualification, op.t_pz,
                op.t_sht_base + op.t_sht_k * tp_param_value(p_product, op.t_sht_param_id),
                p_tp)
        RETURNING id INTO v_new;

        -- операция получает результат предыдущей
        IF v_prev IS NOT NULL THEN
            INSERT INTO route_input(out_op_id, in_op_id, qty, for_qty)
            VALUES (v_new, v_prev, 1, 1);
        END IF;

        -- входные ресурсы операции (материалы или другие изделия)
        FOR inp IN SELECT * FROM typical_process_input WHERE tp_op_id = op.id LOOP
            v_in_op := route_output_op(inp.material_id);
            IF v_in_op IS NULL THEN
                RAISE EXCEPTION 'У изделия % нет ни маршрута, ни позиции закупки', inp.material_id;
            END IF;
            v_qty := inp.qty_base + inp.qty_k * tp_param_value(p_product, inp.qty_param_id);
            IF v_qty > 0 THEN
                INSERT INTO route_input(out_op_id, in_op_id, qty, for_qty)
                VALUES (v_new, v_in_op, v_qty, 1);
            END IF;
        END LOOP;

        v_prev := v_new;
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;
