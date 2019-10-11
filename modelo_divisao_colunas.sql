--trocar os termos: <>
--pelos respectivos nomes de tabelas, colunas e identificador da tabela

CREATE OR REPLACE FUNCTION salvar_colunas()
  RETURNS trigger AS $$
BEGIN
	UPDATE <tabela>
	SET <coluna1> = LEFT(NEW.<coluna_original>, 1),
	<coluna2> = RIGHT(NEW.<coluna_original>, CHAR_LENGTH(NEW.<coluna_original>)-1)
	WHERE <id> = NEW.<id>;
   RETURN NEW;
END;
$$ language plpgsql;

CREATE TRIGGER insert_tabela
  AFTER INSERT
  ON <tabela>
  FOR EACH ROW
  EXECUTE PROCEDURE salvar_colunas();
  
CREATE TRIGGER update_tabela
  AFTER UPDATE OF <coluna_original>
  ON <tabela>
  FOR EACH ROW
  EXECUTE PROCEDURE salvar_colunas();