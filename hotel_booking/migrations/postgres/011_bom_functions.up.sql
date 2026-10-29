-- 011_bom_functions.up.sql
-- SQL-функции BOM

CREATE OR REPLACE FUNCTION bom_active_spec(p_product INTEGER)
RETURNS INTEGER LANGUAGE sql STABLE AS $$
    SELECT id FROM specification
    WHERE product_id = p_product AND spec_type = 'Базовая' AND status = 'Действует'
    LIMIT 1;
$$;

-- B. Прямые строки на дату
CREATE OR REPLACE FUNCTION bom_lines(p_spec INTEGER, p_date DATE)
RETURNS TABLE (line_id INTEGER, source_spec_id INTEGER, component_id INTEGER,
               quantity NUMERIC, ei_id INTEGER, pos INTEGER)
LANGUAGE sql STABLE AS $$
    SELECT l.id, l.spec_id, l.component_id, l.quantity, l.ei_id, l.position
    FROM specification_line l
    WHERE l.spec_id = p_spec
      AND l.action IN ('Состав', 'Добавить', 'Заменить')
      AND l.date_from <= p_date
      AND (l.date_to IS NULL OR l.date_to > p_date)
    UNION ALL
    SELECT b.id, b.spec_id, b.component_id, b.quantity, b.ei_id, b.position
    FROM specification s
    JOIN specification_line b ON b.spec_id = s.base_spec_id
        AND b.action = 'Состав'
        AND b.date_from <= p_date
        AND (b.date_to IS NULL OR b.date_to > p_date)
    WHERE s.id = p_spec AND s.spec_type = 'Модификация'
      AND NOT EXISTS (
          SELECT 1 FROM specification_line m
          WHERE m.spec_id = p_spec
            AND m.action IN ('Исключить', 'Заменить')
            AND m.excluded_component_id = b.component_id
            AND m.date_from <= p_date
            AND (m.date_to IS NULL OR m.date_to > p_date)
      );
$$;

CREATE OR REPLACE FUNCTION bom_explode(p_spec INTEGER, p_date DATE)
RETURNS TABLE (level INTEGER, parent_id INTEGER, component_id INTEGER,
               component_name TEXT, category_name TEXT,
               qty_per_parent NUMERIC, qty_per_product NUMERIC,
               unit_name TEXT, has_spec BOOLEAN, path INTEGER[])
LANGUAGE sql STABLE AS $$
    WITH RECURSIVE t (lvl, parent, comp, q_parent, q_total, unit, path) AS (
        SELECT 1, (SELECT s.product_id FROM specification s WHERE s.id = p_spec),
               l.component_id, l.quantity, l.quantity, l.ei_id, ARRAY[l.component_id]
        FROM bom_lines(p_spec, p_date) l
        UNION ALL
        SELECT t.lvl + 1, t.comp, l.component_id, l.quantity,
               t.q_total * l.quantity, l.ei_id, t.path || l.component_id
        FROM t
        CROSS JOIN LATERAL bom_lines(bom_active_spec(t.comp), p_date) l
        WHERE t.lvl < 30 AND NOT (l.component_id = ANY (t.path))
    )
    SELECT t.lvl, t.parent, t.comp, p.name::TEXT, ce.name::TEXT,
           t.q_parent::NUMERIC, t.q_total::NUMERIC, u.short_name::TEXT,
           bom_active_spec(t.comp) IS NOT NULL, t.path
    FROM t
    JOIN product p ON p.id = t.comp
    LEFT JOIN classification_element ce ON ce.id = p.class_id
    LEFT JOIN unit_of_measure u ON u.id = t.unit
    ORDER BY t.path;
$$;

CREATE OR REPLACE FUNCTION bom_sum_norms(
    p_product INTEGER, p_class INTEGER,
    p_date DATE DEFAULT CURRENT_DATE, p_spec INTEGER DEFAULT NULL)
RETURNS TABLE (component_id INTEGER, component_name TEXT, category_name TEXT,
               total_norm NUMERIC, unit_name TEXT)
LANGUAGE sql STABLE AS $$
    WITH RECURSIVE cls(id) AS (
        SELECT id FROM classification_element WHERE id = p_class
        UNION ALL
        SELECT c.id FROM classification_element c JOIN cls ON c.parent_id = cls.id
    ),
    e AS (SELECT * FROM bom_explode(COALESCE(p_spec, bom_active_spec(p_product)), p_date))
    SELECT e.component_id, e.component_name, e.category_name,
           SUM(e.qty_per_product)::NUMERIC, e.unit_name
    FROM e
    JOIN product p ON p.id = e.component_id
    WHERE NOT e.has_spec AND p.class_id IN (SELECT id FROM cls)
    GROUP BY e.component_id, e.component_name, e.category_name, e.unit_name
    ORDER BY e.component_name;
$$;

CREATE OR REPLACE FUNCTION bom_where_used(p_component INTEGER, p_date DATE DEFAULT CURRENT_DATE)
RETURNS TABLE (level INTEGER, product_id INTEGER, product_name TEXT)
LANGUAGE sql STABLE AS $$
    WITH RECURSIVE up(lvl, pid, path) AS (
        SELECT 1, s.product_id, ARRAY[s.product_id]
        FROM specification s
        JOIN specification_line l ON l.spec_id = s.id
        WHERE l.component_id = p_component AND s.status = 'Действует'
          AND l.date_from <= p_date AND (l.date_to IS NULL OR l.date_to > p_date)
        UNION ALL
        SELECT up.lvl + 1, s.product_id, up.path || s.product_id
        FROM up
        JOIN specification_line l ON l.component_id = up.pid
        JOIN specification s ON s.id = l.spec_id
        WHERE s.status = 'Действует'
          AND l.date_from <= p_date AND (l.date_to IS NULL OR l.date_to > p_date)
          AND NOT (s.product_id = ANY(up.path)) AND up.lvl < 30
    )
    SELECT DISTINCT up.lvl, up.pid, p.name::TEXT
    FROM up JOIN product p ON p.id = up.pid ORDER BY 1, 3;
$$;

CREATE OR REPLACE FUNCTION bom_create_base(p_product INTEGER, p_designation VARCHAR, p_descr TEXT DEFAULT NULL)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_id INTEGER;
BEGIN
    INSERT INTO specification(product_id, designation, spec_type, description)
    VALUES (p_product, p_designation, 'Базовая', p_descr) RETURNING id INTO v_id;
    RETURN v_id;
END; $$;

CREATE OR REPLACE FUNCTION bom_create_modification(p_product INTEGER, p_base_spec INTEGER,
    p_designation VARCHAR, p_descr TEXT DEFAULT NULL)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_id INTEGER;
BEGIN
    INSERT INTO specification(product_id, designation, spec_type, base_spec_id, description)
    VALUES (p_product, p_designation, 'Модификация', p_base_spec, p_descr) RETURNING id INTO v_id;
    RETURN v_id;
END; $$;

CREATE OR REPLACE FUNCTION bom_create_change(p_number VARCHAR, p_date DATE, p_descr TEXT DEFAULT NULL)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_id INTEGER;
BEGIN
    INSERT INTO change_notice(number, date, description)
    VALUES (p_number, p_date, p_descr) RETURNING id INTO v_id;
    RETURN v_id;
END; $$;

CREATE OR REPLACE FUNCTION bom_close_change(p_change INTEGER)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE change_notice SET status = 'Проведено' WHERE id = p_change;
    IF NOT FOUND THEN RAISE EXCEPTION 'Извещение % не найдено', p_change; END IF;
END; $$;

CREATE OR REPLACE FUNCTION bom_change_date(p_change INTEGER)
RETURNS DATE LANGUAGE plpgsql STABLE AS $$
DECLARE v_date DATE; v_status VARCHAR;
BEGIN
    SELECT date, status INTO v_date, v_status FROM change_notice WHERE id = p_change;
    IF v_date IS NULL THEN RAISE EXCEPTION 'Извещение % не найдено', p_change; END IF;
    IF v_status <> 'Открыто' THEN
        RAISE EXCEPTION 'Извещение % уже проведено, изменения запрещены', p_change;
    END IF;
    RETURN v_date;
END; $$;

CREATE OR REPLACE FUNCTION bom_add_line(p_spec INTEGER, p_component INTEGER, p_qty NUMERIC,
    p_unit INTEGER, p_change INTEGER, p_pos INTEGER DEFAULT 0)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_date DATE; v_type VARCHAR; v_id INTEGER;
BEGIN
    v_date := bom_change_date(p_change);
    SELECT spec_type INTO v_type FROM specification WHERE id = p_spec;
    IF v_type IS NULL THEN RAISE EXCEPTION 'Спецификация % не найдена', p_spec; END IF;
    INSERT INTO specification_line(spec_id, position, action, component_id, quantity, ei_id, date_from, notice_from_id)
    VALUES (p_spec, p_pos, CASE v_type WHEN 'Базовая' THEN 'Состав' ELSE 'Добавить' END,
            p_component, p_qty, p_unit, v_date, p_change) RETURNING id INTO v_id;
    RETURN v_id;
END; $$;

CREATE OR REPLACE FUNCTION bom_close_line(p_line INTEGER, p_change INTEGER)
RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE v_date DATE;
BEGIN
    v_date := bom_change_date(p_change);
    UPDATE specification_line SET date_to = v_date, notice_to_id = p_change
    WHERE id = p_line AND date_to IS NULL;
    IF NOT FOUND THEN RAISE EXCEPTION 'Строка % не найдена или уже закрыта', p_line; END IF;
END; $$;

CREATE OR REPLACE FUNCTION bom_change_qty(p_line INTEGER, p_new_qty NUMERIC, p_change INTEGER)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE r specification_line%ROWTYPE; v_date DATE; v_id INTEGER;
BEGIN
    v_date := bom_change_date(p_change);
    SELECT * INTO r FROM specification_line WHERE id = p_line AND date_to IS NULL;
    IF NOT FOUND THEN RAISE EXCEPTION 'Строка % не найдена или уже закрыта', p_line; END IF;
    PERFORM bom_close_line(p_line, p_change);
    INSERT INTO specification_line(spec_id, position, action, excluded_component_id, component_id,
        quantity, ei_id, date_from, notice_from_id)
    VALUES (r.spec_id, r.position, r.action, r.excluded_component_id, r.component_id,
            p_new_qty, r.ei_id, v_date, p_change) RETURNING id INTO v_id;
    RETURN v_id;
END; $$;

CREATE OR REPLACE FUNCTION bom_replace_component(p_line INTEGER, p_new_component INTEGER,
    p_new_qty NUMERIC, p_change INTEGER)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE r specification_line%ROWTYPE; v_date DATE; v_id INTEGER;
BEGIN
    v_date := bom_change_date(p_change);
    SELECT * INTO r FROM specification_line WHERE id = p_line AND date_to IS NULL;
    IF NOT FOUND THEN RAISE EXCEPTION 'Строка % не найдена или уже закрыта', p_line; END IF;
    PERFORM bom_close_line(p_line, p_change);
    INSERT INTO specification_line(spec_id, position, action, excluded_component_id, component_id,
        quantity, ei_id, date_from, notice_from_id)
    VALUES (r.spec_id, r.position, r.action, r.excluded_component_id, p_new_component,
            p_new_qty, r.ei_id, v_date, p_change) RETURNING id INTO v_id;
    RETURN v_id;
END; $$;

CREATE OR REPLACE FUNCTION bom_mod_exclude(p_mod_spec INTEGER, p_base_component INTEGER, p_change INTEGER)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_date DATE; v_id INTEGER;
BEGIN
    v_date := bom_change_date(p_change);
    INSERT INTO specification_line(spec_id, action, excluded_component_id, date_from, notice_from_id)
    VALUES (p_mod_spec, 'Исключить', p_base_component, v_date, p_change) RETURNING id INTO v_id;
    RETURN v_id;
END; $$;

CREATE OR REPLACE FUNCTION bom_mod_replace(p_mod_spec INTEGER, p_base_component INTEGER,
    p_new_component INTEGER, p_qty NUMERIC, p_unit INTEGER, p_change INTEGER)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_date DATE; v_id INTEGER;
BEGIN
    v_date := bom_change_date(p_change);
    INSERT INTO specification_line(spec_id, action, excluded_component_id, component_id,
        quantity, ei_id, date_from, notice_from_id)
    VALUES (p_mod_spec, 'Заменить', p_base_component, p_new_component,
            p_qty, p_unit, v_date, p_change) RETURNING id INTO v_id;
    RETURN v_id;
END; $$;