
-- QUESTÃO 01

CREATE MATERIALIZED VIEW mv_driver_season_summary AS
SELECT
    r.year,
    d.driver_id,
    CONCAT(d.firstname, ' ', d.lastname) AS piloto,
    COUNT (*) AS total_corridas,
    COUNT(CASE WHEN rd.position_number = 1 THEN 1 END) AS vitorias,
    COUNT(CASE WHEN rd.position_number <= 3 THEN 1 END) AS podios,
    COUNT(CASE WHEN rd.race_reason_retired IS NOT NULL THEN 1 END) AS abandonos,
    SUM(COALESCE(rd.points, 0)) AS total_pontos
FROM race_data rd
WHERE rd.type = 'RACE_RESULT'
GROUP BY
    r.year,
    d.driver_id,
    d.firstname,
    d.lastname ;


-- QUESTÃO O3
CREATE FUNCTION impedir_exclusao_piloto()
RETURNS TRIGGER AS $$
DECLARE
    nome_piloto TEXT;
BEGIN
    SELECT CONCAT(f.nome, ' ', l.nome)
    INTO nome_piloto
    FROM driver
    WHERE driver_id = OLD.driver_id;

    IF EXISTS (
        SELECT 1
        FROM race_data
        WHERE driver_id = OLD.driver_id
    ) THEN
        RAISE EXCEPTION
            'Não é possível excluir o piloto',
            nome_piloto;
    END IF;

    RETURN OLD;
END;

CREATE TRIGGER trigger_impedir_exclusao_piloto
BEFORE DELETE ON driver
FOR EACH ROW
EXECUTE FUNCTION impedir_exclusao_piloto();
