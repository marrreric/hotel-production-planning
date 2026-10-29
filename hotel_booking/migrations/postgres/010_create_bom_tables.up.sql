-- 010_create_bom_tables.up.sql
-- Модуль BOM для отеля. Таблицы, ограничения, триггеры.


-- 1. Справочник единиц измерения
CREATE TABLE IF NOT EXISTS unit_of_measure (
    id SERIAL PRIMARY KEY,
    code VARCHAR(16) NOT NULL UNIQUE,
    name VARCHAR(64) NOT NULL,
    short_name VARCHAR(16) NOT NULL,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO unit_of_measure (code, name, short_name, sort_order) VALUES
('PCS',  'Штука',           'шт',   1),
('KG',   'Килограмм',       'кг',   2),
('G',    'Грамм',           'г',    3),
('L',    'Литр',            'л',    4),
('ML',   'Миллилитр',       'мл',   5),
('M',    'Метр',            'м',    6),
('M2',   'Квадратный метр', 'м²',   7),
('M3',   'Кубический метр', 'м³',   8),
('MIN',  'Минута',          'мин',  9),
('HOUR', 'Час',             'ч',    10),
('SET',  'Комплект',        'компл',11),
('PAIR', 'Пара',            'пара', 12),
('PORTION', 'Порция',       'порц', 13)
ON CONFLICT (code) DO NOTHING;

-- 2. Расширение product полями BOM
ALTER TABLE product 
ADD COLUMN IF NOT EXISTS designation VARCHAR(128),
ADD COLUMN IF NOT EXISTS base_product_id INTEGER REFERENCES product(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS is_modification BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS ei_id INTEGER REFERENCES unit_of_measure(id);

CREATE INDEX IF NOT EXISTS idx_product_base ON product(base_product_id);
CREATE INDEX IF NOT EXISTS idx_product_designation ON product(designation);

-- 3. Извещения об изменении
CREATE TABLE IF NOT EXISTS change_notice (
    id SERIAL PRIMARY KEY,
    number VARCHAR(50) NOT NULL UNIQUE,
    date DATE NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'Открыто'
        CHECK (status IN ('Открыто', 'Проведено'))
);

-- 4. Заголовок спецификации
CREATE TABLE IF NOT EXISTS specification (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES product(id) ON DELETE CASCADE,
    designation VARCHAR(50) NOT NULL UNIQUE,
    spec_type VARCHAR(20) NOT NULL
        CHECK (spec_type IN ('Базовая', 'Модификация')),
    base_spec_id INTEGER REFERENCES specification(id),
    status VARCHAR(20) NOT NULL DEFAULT 'Действует'
        CHECK (status IN ('Черновик', 'Действует', 'Архив')),
    description TEXT,
    CONSTRAINT chk_spec_type_parent CHECK (
        (spec_type = 'Базовая' AND base_spec_id IS NULL) OR
        (spec_type = 'Модификация' AND base_spec_id IS NOT NULL)
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_spec_one_active_base
ON specification(product_id)
WHERE spec_type = 'Базовая' AND status = 'Действует';

-- 5. Строки спецификации
CREATE TABLE IF NOT EXISTS specification_line (
    id SERIAL PRIMARY KEY,
    spec_id INTEGER NOT NULL REFERENCES specification(id) ON DELETE CASCADE,
    position INTEGER NOT NULL DEFAULT 0,
    action VARCHAR(20) NOT NULL DEFAULT 'Состав'
        CHECK (action IN ('Состав', 'Добавить', 'Заменить', 'Исключить')),
    excluded_component_id INTEGER REFERENCES product(id),
    component_id INTEGER REFERENCES product(id),
    quantity NUMERIC(14, 6),
    ei_id INTEGER REFERENCES unit_of_measure(id),
    date_from DATE NOT NULL,
    date_to DATE,
    notice_from_id INTEGER REFERENCES change_notice(id),
    notice_to_id INTEGER REFERENCES change_notice(id),
    CONSTRAINT chk_line_period CHECK (date_to IS NULL OR date_to > date_from),
    CONSTRAINT chk_line_quantity CHECK (quantity IS NULL OR quantity > 0),
    CONSTRAINT chk_line_action CHECK (
        (action IN ('Состав', 'Добавить')
            AND excluded_component_id IS NULL
            AND component_id IS NOT NULL
            AND quantity IS NOT NULL
            AND ei_id IS NOT NULL) OR
        (action = 'Заменить'
            AND excluded_component_id IS NOT NULL
            AND component_id IS NOT NULL
            AND quantity IS NOT NULL
            AND ei_id IS NOT NULL) OR
        (action = 'Исключить'
            AND excluded_component_id IS NOT NULL
            AND component_id IS NULL
            AND quantity IS NULL
            AND ei_id IS NULL)
    )
);

CREATE INDEX IF NOT EXISTS ix_line_spec ON specification_line(spec_id);
CREATE INDEX IF NOT EXISTS ix_line_component ON specification_line(component_id);

-- 6. Триггер контроля типа
CREATE OR REPLACE FUNCTION trg_spec_check_base() RETURNS trigger AS $$
BEGIN
    IF NEW.spec_type = 'Модификация' THEN
        IF NOT EXISTS (
            SELECT 1 FROM specification
            WHERE id = NEW.base_spec_id AND spec_type = 'Базовая'
        ) THEN
            RAISE EXCEPTION 'Модификация должна ссылаться на базовую спецификацию';
        END IF;
        IF NEW.product_id = (
            SELECT product_id FROM specification WHERE id = NEW.base_spec_id
        ) THEN
            RAISE EXCEPTION 'Модификация должна относиться к другому изделию';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_spec_check_base ON specification;
CREATE TRIGGER trg_spec_check_base
BEFORE INSERT OR UPDATE ON specification
FOR EACH ROW EXECUTE FUNCTION trg_spec_check_base();

-- 7. Триггер защиты от циклов
CREATE OR REPLACE FUNCTION trg_line_check_cycle() RETURNS trigger AS $$
DECLARE v_owner INTEGER;
BEGIN
    IF NEW.component_id IS NULL THEN
        RETURN NEW;
    END IF;
    
    SELECT product_id INTO v_owner FROM specification WHERE id = NEW.spec_id;
    
    IF NEW.component_id = v_owner THEN
        RAISE EXCEPTION 'Изделие не может входить в состав самого себя';
    END IF;
    
    IF EXISTS (
        WITH RECURSIVE r(pid) AS (
            SELECT NEW.component_id
            UNION
            SELECT sl.component_id FROM r
            JOIN specification s ON s.product_id = r.pid AND s.spec_type = 'Базовая'
            JOIN specification_line sl ON sl.spec_id = s.id
                AND sl.action IN ('Состав', 'Добавить', 'Заменить')
        )
        SELECT 1 FROM r WHERE pid = v_owner
    ) THEN
        RAISE EXCEPTION 'Обнаружен цикл: изделие % уже входит в состав компонента %',
            v_owner, NEW.component_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_line_check_cycle ON specification_line;
CREATE TRIGGER trg_line_check_cycle
BEFORE INSERT OR UPDATE OF component_id, spec_id ON specification_line
FOR EACH ROW EXECUTE FUNCTION trg_line_check_cycle();