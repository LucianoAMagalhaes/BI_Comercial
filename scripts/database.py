import os
from dotenv import load_dotenv
from sqlalchemy import create_engine

def get_db_engine():
    """
    Carrega as variáveis de ambiente do arquivo .env e 
    retorna uma engine de conexão do SQLAlchemy.
    """

    # --- Carregar Variáveis de Ambiente ---
    script_dir = os.path.dirname(__file__)
    env_path = os.path.join(script_dir, '..', '.env')

    if not os.path.exists(env_path):
        print(f"Atenção: Arquivo .env não encontrado em {env_path}")
        print("Tentando carregar variáveis do ambiente do sistema.")

    load_dotenv(dotenv_path=env_path)

    # Pega a string de conexão do ambiente
    connection_string = os.environ.get("DATABASE_URL")

    if not connection_string:
        print("Erro: A variável de ambiente 'DATABASE_URL' não foi encontrada.")
        print("Verifique seu arquivo .env ou as variáveis de ambiente do sistema.")
        return None
    
    # --- Criar a Engine ---
    try:
        engine = create_engine(connection_string)
        print("Engine de conexão com o banco de dados criada com sucesso.")
        return engine
    except Exception as e:
        print(f"Erro ao criar a engine do banco: {e}")
        return None