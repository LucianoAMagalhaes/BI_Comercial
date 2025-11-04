# Bibliotecas
import pandas as pd
import glob
import os
import time
from database import get_db_engine

# --- 1. Obter a Engine do Banco ---
print("Iniciando script de carga de dados...")
engine = get_db_engine()

if engine is None:
    print("Falha ao obter a engine do banco. Abortando o script.")
    exit()

# --- 2. Caminho dos Dados ---
script_dir = os.path.dirname(__file__)
csv_folder_path = os.path.join(script_dir, '..', 'data')

csv_files = glob.glob(os.path.join(csv_folder_path, '*.csv'))

if not csv_files:
    print(f"Nenhum arquivo .csv encontrado na pasta: {csv_folder_path}")
    print("Certifique-se de baixar os arquivos do Kaggle e colocá-los lá.")
    exit()

print(f"Encontrados {len(csv_files)} arquivos CSV. Iniciando a carga...")

# --- 3. Loop de Carga (Extract & Load) ---
start_total_time = time.time()

for file_path in csv_files:
    try:
        start_file_time = time.time()

        file_name = os.path.basename(file_path)
        table_name = file_name.replace('_dataset.csv', '').replace('.csv', '').replace('-','_')

        print(f"\nCarregando arquivo: {file_name} -> Tabela: {table_name}")

        df = pd.read_csv(file_path)
        df.columns = [col.lower().strip() for col in df.columns]

        df.to_sql(table_name, engine, if_exists='replace', index=False)

        end_file_time = time.time()
        print(f"Tabela '{table_name}' carregada com {len(df)} linhas em {end_file_time - start_file_time:.2f} segundos.")
    except Exception as e:
        print(f"Erro ao carregar o arquivo {file_name}: {e}")

end_total_time = time.time()
print(f"\n--- Carga Concluída ---")
print(f"Tempo total: {end_total_time - start_total_time:.2f} segundos.")