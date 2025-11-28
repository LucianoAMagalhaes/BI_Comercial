"""
Módulo de Configuração de Banco de Dados
----------------------------------------
Responsável por gerenciar a conexão com o PostgreSQL utilizando SQLAlchemy.
Este módulo implementa o padrão de carregar credenciais sensíveis via variáveis 
de ambiente (.env), garantindo que senhas não sejam expostas no código-fonte.

Arquitetura:
    - Olist BI Pipeline
    - Etapa: Configuração / Cross-cutting
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine

def get_db_engine():
    """
    Cria e retorna uma Engine do SQLAlchemy para conexão com o banco de dados.
    
    O processo segue os princípios '12-Factor App' de configuração:
    1. Localiza o arquivo .env na raiz do projeto.
    2. Carrega as variáveis de ambiente.
    3. Instancia a engine de conexão.

    Returns:
        sqlalchemy.engine.Engine: Objeto de conexão pronto para uso (ou None em caso de falha).
    """

    # --- 1. Definição Dinâmica de Caminhos ---
    # Garante que o script encontre o .env independente do diretório de execução.
    # __file__ é o caminho deste script (dentro de /scripts).
    # Usamos '..' para voltar um nível até a raiz do projeto onde o .env reside.
    script_dir = os.path.dirname(os.path.abspath(__file__))
    env_path = os.path.join(script_dir, '..', '.env')

    # Validação de existência do arquivo de configuração
    if not os.path.exists(env_path):
        print(f"⚠️  Aviso: Arquivo .env não encontrado no caminho esperado: {env_path}")
        print("   Tentando carregar variáveis diretamente do ambiente do sistema (Docker/OS).")

    # Carrega as variáveis do arquivo .env para o os.environ
    load_dotenv(dotenv_path=env_path)

    # --- 2. Recuperação de Credenciais ---
    # Busca a string de conexão (DSN). Ex: postgresql://user:pass@host:5432/db
    connection_string = os.environ.get("DATABASE_URL")

    # Fail-Fast: Aborta imediatamente se a configuração crítica estiver ausente
    if not connection_string:
        print("❌ Erro Crítico: A variável de ambiente 'DATABASE_URL' não foi definida.")
        print("   Ação: Verifique seu arquivo .env ou as variáveis de ambiente do container.")
        return None
    
    # --- 3. Criação da Engine ---
    try:
        # Cria a engine que gerencia o pool de conexões com o Postgres
        engine = create_engine(connection_string)
        print("✅ Engine de conexão com o banco de dados criada com sucesso.")
        return engine
        
    except Exception as e:
        print(f"❌ Erro ao inicializar a engine do SQLAlchemy: {e}")
        return None

if __name__ == "__main__":
    # Bloco de teste rápido: permite rodar este script isoladamente para verificar a conexão
    get_db_engine()