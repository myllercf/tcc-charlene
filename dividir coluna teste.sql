--CREATE TABLE tabela(
	id SERIAL PRIMARY KEY NOT NULL,
	coluna_original VARCHAR(3) NOT NULL,
	coluna1 varchar(1) ,
	coluna2 varchar(2) 
);

select * from tabela ORDER BY id ASC;

INSERT INTO tabela (coluna_original) values ('012');
UPDATE tabela SET coluna_original = '345' WHERE id = 4;
SELECT LEFT(coluna_original, 1) from tabela;
SELECT RIGHT(coluna_original, CHAR_LENGTH(coluna_original)-1) from tabela;


CREATE OR REPLACE FUNCTION salvar_colunas()
  RETURNS trigger AS $$
--DECLARE
	--v_soma tabela.coluna_original%TYPE;
BEGIN
	UPDATE tabela
	SET coluna1 = LEFT(NEW.coluna_original, 1),
	coluna2 = RIGHT(NEW.coluna_original, CHAR_LENGTH(NEW.coluna_original)-1)
	WHERE id = NEW.id;
 
   RETURN NEW;
END;
$$ language plpgsql;

CREATE TRIGGER insert_tabela
  AFTER INSERT
  ON tabela
  FOR EACH ROW
  EXECUTE PROCEDURE salvar_colunas();
  
CREATE TRIGGER update_tabela
  AFTER UPDATE OF coluna_original
  ON tabela
  FOR EACH ROW
  EXECUTE PROCEDURE salvar_colunas();