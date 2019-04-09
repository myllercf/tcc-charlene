--aqui é para criar a coluna nova que vai ter o somatorio das fachadas
--eu chamei de soma_acumulada. outra coisa é o tipo de dado
--ele deve ser igual ao da coluna que vai ser somada. eu criei como numeric
ALTER TABLE public.caruaru_poligono
	ADD COLUMN soma_acumulada numeric;



--aqui é onde vai acontecer a iteracao pra somar as fachadas
--esse v_quadra é o parametro para ele so somar de acordo com as quadras como voce tinha falado
--preciso prestar atencao em algumas coisas: nome da tabela, nome da coluna que seja somar, nome da coluna somatorio
CREATE OR REPLACE FUNCTION somar_frente_casas(v_quadra caruaru_poligono.quadra%TYPE)
RETURNS void AS $$
DECLARE
    v_soma caruaru_poligono.face%TYPE:= 0;
    poligono_linha caruaru_poligono%ROWTYPE;
    v_cursor CURSOR FOR (
        SELECT * FROM caruaru_poligono 
        WHERE quadra = v_quadra) FOR UPDATE;
BEGIN
OPEN v_cursor;
LOOP
    FETCH v_cursor INTO poligono_linha;
    IF NOT found THEN
        EXIT ;
    END IF;
    v_soma = v_soma + poligono_linha.face;
    UPDATE caruaru_poligono SET soma_acumulada = v_soma
    WHERE CURRENT OF v_cursor;
END LOOP;
CLOSE v_cursor;
EXCEPTION WHEN others THEN
    RAISE notice '% %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE 'plpgsql';



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
