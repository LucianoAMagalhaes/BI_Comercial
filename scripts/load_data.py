"""
Módulo de Ingestão de Dados (Extract & Load)
--------------------------------------------
Responsável por automatizar o processo de carga de dados brutos (arquivos CSV)
para o Data Warehouse (PostgreSQL).

Funcionalidades:
    1. Varredura dinâmica do diretório de dados.
    2. Normalização básica de nomes de tabelas e colunas.
    3. Carga em lote para o banco de dados SQL.
    4. Monitoramento de tempo de execução.

Arquitetura:
    - Olist BI Pipeline
    - Etapa: Ingestão (Raw Layer)
"""

import pandas as pd
import glob
import os
import time
from database import get_db_engine

def load_csvs_to_postgres():
    """
    Executa o fluxo principal de carga:
    Lê todos os CSVs da pasta /data e os insere no Postgres como tabelas individuais.
    """
    
    # --- 1. Inicialização da Conexão ---
    print("🚀 Iniciando pipeline de carga de dados...")
    engine = get_db_engine()

    if engine is None:
        print("❌ Abortando: Não foi possível conectar ao banco de dados.")
        return

    # --- 2. Descoberta de Arquivos (File Discovery) ---
    # Define caminhos relativos para garantir execução em qualquer ambiente (Local/Docker)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_folder_path = os.path.join(script_dir, '..', 'data')

    # Usa glob para listar todos os arquivos .csv na pasta alvo
    csv_files = glob.glob(os.path.join(csv_folder_path, '*.csv'))

    if not csv_files:
        print(f"⚠️  Aviso: Nenhum arquivo .csv encontrado em: {csv_folder_path}")
        print("   Ação: Verifique se o download do Kaggle foi realizado.")
        return

    print(f"📂 Encontrados {len(csv_files)} arquivos para processamento.")

    # --- 3. Processamento em Lote (Batch Processing) ---
    start_total_time = time.time()

    for file_path in csv_files:
        try:
            start_file_time = time.time()
            
            # 3.1. Tratamento do Nome da Tabela
            # Ex: 'olist_customers_dataset.csv' -> 'olist_customers'
            file_name = os.path.basename(file_path)
            table_name = file_name.replace('_dataset.csv', '').replace('.csv', '').replace('-', '_')

            print(f"\n🔄 Processando: {file_name} -> Tabela SQL: {table_name}")

            # 3.2. Leitura e Limpeza Básica (Pandas)
            # Carrega o CSV em memória (DataFrame)
            df = pd.read_csv(file_path)
            
            # Normalização de Colunas: minúsculas e sem espaços (Boas práticas de SQL)
            df.columns = [col.lower().strip() for col in df.columns]

            # 3.3. Carga no Banco (Load)
            # 'if_exists="replace"': Recria a tabela a cada execução (Full Refresh)
            # Para grandes volumes, considerar 'append' ou estratégia incremental.
            df.to_sql(table_name, engine, if_exists='replace', index=False)
            
            end_file_time = time.time()
            elapsed_time = end_file_time - start_file_time
            print(f"✅ Sucesso: {len(df)} registros carregados em {elapsed_time:.2f}s.")

        except Exception as e:
            # Captura erros individuais para não parar todo o pipeline
            print(f"❌ Erro ao carregar arquivo {file_name}: {e}")

    end_total_time = time.time()
    total_duration = end_total_time - start_total_time
    print(f"\n🏁 Carga Concluída! Tempo total de execução: {total_duration:.2f} segundos.")

if __name__ == "__main__":
    load_csvs_to_postgres()