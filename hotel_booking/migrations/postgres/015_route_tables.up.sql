-- 015_route_tables.up.sql
-- Лаба 6. Маршрутная технология: таблицы

-- 1. Подразделения (СХД)
CREATE TABLE IF NOT EXISTS department (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL UNIQUE
);

-- 2. Групповые рабочие центры (ГРЦ), каждый в одном подразделении
CREATE TABLE IF NOT EXISTS work_center (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL UNIQUE,
    department_id INTEGER NOT NULL REFERENCES department(id)
);

-- 3. Часовые ставки профессий (сами профессии - ветка в classification_element)
CREATE TABLE IF NOT EXISTS profession_rate (
    profession_id INTEGER PRIMARY KEY REFERENCES classification_element(id) ON DELETE CASCADE,
    hourly_rate NUMERIC(10, 2) NOT NULL CHECK (hourly_rate > 0)
);

-- 4. Типовой ТП (шаблон маршрута)
CREATE TABLE IF NOT EXISTS typical_process (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL UNIQUE,
    description TEXT
);

-- 5. Параметры типового ТП (например, площадь номера)
CREATE TABLE IF NOT EXISTS typical_process_param (
    id SERIAL PRIMARY KEY,
    tp_id INTEGER NOT NULL REFERENCES typical_process(id) ON DELETE CASCADE,
    code VARCHAR(32) NOT NULL,
    name VARCHAR(128) NOT NULL,
    unit VARCHAR(16),
    UNIQUE (tp_id, code)
);

-- 6. Изделие-Операция (TM1): операция маршрута или позиция закупки
CREATE TABLE IF NOT EXISTS route_operation (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES product(id) ON DELETE CASCADE,
    kind VARCHAR(20) NOT NULL CHECK (kind IN ('Операция', 'Закупка')),
    -- поля операции
    num INTEGER,                                              -- номер: 10, 20, 30...
    name VARCHAR(256),
    op_class_id INTEGER REFERENCES classification_element(id),    -- класс тех. операции
    work_center_id INTEGER REFERENCES work_center(id),            -- ГРЦ
    profession_id INTEGER REFERENCES classification_element(id),  -- профессия
    qualification INTEGER CHECK (qualification BETWEEN 1 AND 6), -- разряд
    t_pz NUMERIC(10, 2),   -- подготовительно-заключительное время, мин (на партию)
    t_sht NUMERIC(10, 2),  -- штучное время, мин (на 1 шт)
    -- поля закупки
    ei_id INTEGER REFERENCES unit_of_measure(id),
    unit_price NUMERIC(12, 4),                                -- цена за 1 ед. изм.
    -- из какого типового ТП создана операция (если из него)
    tp_id INTEGER REFERENCES typical_process(id) ON DELETE SET NULL,
    CONSTRAINT chk_route_kind CHECK (
        (kind = 'Операция'
            AND num IS NOT NULL AND op_class_id IS NOT NULL
            AND work_center_id IS NOT NULL AND profession_id IS NOT NULL
            AND qualification IS NOT NULL
            AND t_pz IS NOT NULL AND t_sht IS NOT NULL) OR
        (kind = 'Закупка'
            AND ei_id IS NOT NULL AND unit_price IS NOT NULL)
    )
);

-- у изделия не может быть двух операций с одним номером
CREATE UNIQUE INDEX IF NOT EXISTS ux_route_op_num
    ON route_operation(product_id, num) WHERE kind = 'Операция';
-- у материала одна позиция закупки
CREATE UNIQUE INDEX IF NOT EXISTS ux_route_purchase
    ON route_operation(product_id) WHERE kind = 'Закупка';

-- 7. Позиция входного ресурса (IN_RES1)
-- "для получения for_qty единиц результата out_op нужно qty единиц результата in_op"
CREATE TABLE IF NOT EXISTS route_input (
    out_op_id INTEGER NOT NULL REFERENCES route_operation(id) ON DELETE CASCADE,
    in_op_id INTEGER NOT NULL REFERENCES route_operation(id) ON DELETE CASCADE,
    qty NUMERIC(14, 6) NOT NULL CHECK (qty > 0),
    for_qty NUMERIC(14, 6) NOT NULL DEFAULT 1 CHECK (for_qty > 0),
    PRIMARY KEY (out_op_id, in_op_id),
    CHECK (out_op_id <> in_op_id)
);

-- 8. Операции типового ТП: штучное время = t_sht_base + t_sht_k * параметр
CREATE TABLE IF NOT EXISTS typical_process_op (
    id SERIAL PRIMARY KEY,
    tp_id INTEGER NOT NULL REFERENCES typical_process(id) ON DELETE CASCADE,
    num INTEGER NOT NULL,
    name VARCHAR(256) NOT NULL,
    op_class_id INTEGER NOT NULL REFERENCES classification_element(id),
    work_center_id INTEGER NOT NULL REFERENCES work_center(id),
    profession_id INTEGER NOT NULL REFERENCES classification_element(id),
    qualification INTEGER NOT NULL CHECK (qualification BETWEEN 1 AND 6),
    t_pz NUMERIC(10, 2) NOT NULL DEFAULT 0,
    t_sht_base NUMERIC(10, 2) NOT NULL DEFAULT 0,
    t_sht_k NUMERIC(10, 4) NOT NULL DEFAULT 0,
    t_sht_param_id INTEGER REFERENCES typical_process_param(id),
    UNIQUE (tp_id, num)
);

-- 9. Материалы операций типового ТП: расход = qty_base + qty_k * параметр
CREATE TABLE IF NOT EXISTS typical_process_input (
    id SERIAL PRIMARY KEY,
    tp_op_id INTEGER NOT NULL REFERENCES typical_process_op(id) ON DELETE CASCADE,
    material_id INTEGER NOT NULL REFERENCES product(id),
    qty_base NUMERIC(14, 6) NOT NULL DEFAULT 0,
    qty_k NUMERIC(14, 6) NOT NULL DEFAULT 0,
    qty_param_id INTEGER REFERENCES typical_process_param(id)
);

-- 10. Значения параметров типового ТП для конкретного изделия
CREATE TABLE IF NOT EXISTS product_tp_value (
    product_id INTEGER NOT NULL REFERENCES product(id) ON DELETE CASCADE,
    param_id INTEGER NOT NULL REFERENCES typical_process_param(id) ON DELETE CASCADE,
    value NUMERIC(14, 4) NOT NULL,
    PRIMARY KEY (product_id, param_id)
);
