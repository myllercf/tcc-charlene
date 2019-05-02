--aqui é para criar a coluna nova que vai ter o somatorio das fachadas
--eu chamei de soma_acumulada. outra coisa é o tipo de dado
--ele deve ser igual ao da coluna que vai ser somada. eu criei como numeric
ALTER TABLE public."LOTES" ADD COLUMN soma_acumulada numeric;



--aqui é onde vai acontecer a iteracao pra somar as fachadas
--esse v_quadra é o parametro para ele so somar de acordo com as quadras como voce tinha falado
--preciso prestar atencao em algumas coisas: nome da tabela, nome da coluna que seja somar, nome da coluna somatorio
CREATE OR REPLACE FUNCTION somar_frente_casas(v_lote "LOTES".lote_%TYPE)
RETURNS void AS $$
DECLARE
    v_soma "LOTES"."TESTADA"%TYPE:= 0;
    poligono_linha "LOTES"%ROWTYPE;
    v_cursor CURSOR FOR (
        SELECT * FROM "LOTES" 
        WHERE lote_ = v_lote) FOR UPDATE;
BEGIN
OPEN v_cursor;
LOOP
    FETCH v_cursor INTO poligono_linha;
    IF NOT found THEN
        EXIT ;
    END IF;
    v_soma = v_soma + poligono_linha."TESTADA";
    UPDATE "LOTES" SET soma_acumulada = v_soma
    WHERE CURRENT OF v_cursor;
END LOOP;
CLOSE v_cursor;
EXCEPTION WHEN others THEN
    RAISE notice '% %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE 'plpgsql';

--cricao do gatilho para executar o calculo a cada insert e update
--insert
CREATE OR REPLACE FUNCTION trigger_somar_frente_insert_update()
	RETURNS trigger AS
$$
BEGIN
	PERFORM somar_frente_casas(NEW.lote_);
	RETURN NEW;
END;
$$ language plpgsql stable;
--delete
CREATE OR REPLACE FUNCTION trigger_somar_frente_delete()
	RETURNS trigger AS
$$
BEGIN
	PERFORM somar_frente_casas(OLD.lote_);
	RETURN NEW;
END;
$$ language plpgsql stable;


--associa a trigger com a tabela das fachadas
--insert
CREATE TRIGGER trigger_caruaru_poligono_insert_update
	AFTER INSERT OR UPDATE OF "TESTADA"
	ON "LOTES"
	FOR EACH ROW
	EXECUTE PROCEDURE trigger_somar_frente_insert_update();
--delete
CREATE TRIGGER trigger_caruaru_poligono_delete
	AFTER DELETE
	ON "LOTES"
	FOR EACH ROW
	EXECUTE PROCEDURE trigger_somar_frente_delete();

------------------------ // -----------------------------

--DROP TRIGGER trigger_caruaru_poligono_insert_update ON caruaru_poligono
--DROP TRIGGER trigger_caruaru_poligono_delete ON caruaru_poligono

--aqui é para esconder as colunas que voce queira.
--primeiro voce vai escolher o nome que quer. como se fosse uma tabela. agora esta noma_como_se_fosse_tabela
CREATE VIEW noma_como_se_fosse_tabela AS
--aqui voce vai dizer quais colunas devem aparecer
--por ex: eu deixei o id a quadra e o somatorio
    SELECT id, quadra, geom, soma_acumulada FROM caruaru_poligono ;

--o nome que voce de vai ser a nova tabela que voce vai usar. olha o ex
select * from noma_como_se_fosse_tabela;

--para testar se esta tudo certo é so rodar a consulta
--tem que informar qual a quadra que se deseja fazer a soma
SELECT somar_frente_casas('1');
