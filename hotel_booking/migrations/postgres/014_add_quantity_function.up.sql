-- 014_add_quantity_function.up.sql
-- Функция расчёта норм расхода на заданное количество единиц изделия
-- (например, на N ночей в номере)

CREATE OR REPLACE FUNCTION bom_sum_norms_for_qty(
    p_product INTEGER,
    p_class INTEGER,
    p_quantity NUMERIC,
    p_date DATE DEFAULT CURRENT_DATE,
    p_spec INTEGER DEFAULT NULL
)
RETURNS TABLE (
    component_id INTEGER,
    component_name TEXT,
    category_name TEXT,
    total_norm NUMERIC,
    unit_name TEXT
) LANGUAGE sql STABLE AS $$
    -- Вызываем стандартную функцию bom_sum_norms
    -- и умножаем total_norm на p_quantity
    SELECT 
        e.component_id,
        e.component_name,
        e.category_name,
        (e.total_norm * p_quantity)::NUMERIC AS total_norm,
        e.unit_name
    FROM bom_sum_norms(p_product, p_class, p_date, p_spec) e;
$$;

COMMENT ON FUNCTION bom_sum_norms_for_qty(INTEGER, INTEGER, NUMERIC, DATE, INTEGER) 
IS 'Сводные нормы расхода компонентов изделия по классу ресурсов, умноженные на заданное количество';