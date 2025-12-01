# Olist Retail Analytics: Estratégia, CRM e Previsão de Vendas 🇧🇷

![Status do Projeto](https://img.shields.io/badge/Status-Concluído-success?style=for-the-badge&logo=git&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-Pro-yellow?style=for-the-badge&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-ETL-blue?style=for-the-badge&logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/PostgreSQL-DW-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker&logoColor=white)

> **Uma suíte completa de Business Intelligence (End-to-End) para e-commerce, transformando dados brutos em decisões estratégicas de Vendas.**

---

## 🖼️ Visão Geral do Dashboard

![Home Page](docs/images/home.png)  
*Capa do Projeto: Interface de navegação estilo App com modo escuro (Dark Mode) e foco em UX.*

![Visão Geral de Vendas](docs/images/page_vendas.png)  
*Visão Geral Vendas: Interface de Análise geral das vendas*

![Cesta de Compras](docs/images/page_cross_sell.png)  
*Cesta de Compras: Interface de Cesta de Compras*

![Crm e Clientes](docs/images/page_crm.png)  
*Visão Geral Vendas: Interface de Análise de perfil de clientes*

![Analise Preditiva](docs/images/page_analise_preditiva.png)  
*Visão Geral Vendas: Interface de previsão e simulação de cenários*

### 🔗 Links
- [**Acesse o Dashboard Interativo (NovyPro)**](#) *(Insira seu link aqui)*

---

## 💼 O Problema de Negócio

A **Olist** é uma das maiores plataformas de e-commerce do Brasil, conectando pequenas empresas aos grandes marketplaces. Com um volume massivo de transações e dados fragmentados em arquivos CSV, a gestão estratégica enfrentava desafios clássicos de varejo:

1.  **Visibilidade de Performance:** Dificuldade em acompanhar métricas de crescimento real (YoY) isolando a sazonalidade natural do varejo.
2.  **Retenção de Clientes (CRM):** Baixa visibilidade sobre quem são os clientes VIPs e quem está em risco de Churn (abandono), dado o modelo de compra esporádica.
3.  **Oportunidades de Cross-Sell:** Desconhecimento sobre a afinidade entre produtos ("Quem compra X, leva Y?"), perdendo oportunidades de aumentar o ticket médio.
4.  **Previsibilidade:** Falta de ferramentas estatísticas para projetar cenários futuros de faturamento e estipular metas agressivas mas realistas.

**Minha Solução:** Construí uma arquitetura de dados moderna e um dashboard analítico para responder a essas perguntas e guiar a estratégia comercial.

---

## 🏗️ Arquitetura Técnica

O projeto não se limita ao visual. Foi construído um pipeline de engenharia de dados robusto seguindo o padrão **ELT (Extract, Load, Transform)**:

```mermaid
graph LR
    A[Dados Brutos (CSV)] -->|Python + Pandas| B(PostgreSQL / Docker);
    B -->|SQL Views| C{Star Schema};
    C -->|Import| D[Power BI];
    D -->|DAX| E[Dashboard Interativo];
```

---

## 🛠️ Tech Stack & Engenharia

- **Python (Pandas & SQLAlchemy):** Script de ingestão automatizado (Extract & Load) que varre diretórios, normaliza nomes de colunas (snake_case) e carrega dados em lote para o banco.
- **PostgreSQL & Docker:** Data Warehouse rodando em container isolado, garantindo reprodutibilidade do ambiente e facilidade de deploy.
- **SQL Avançado (Transformation):**
   - Resolução de Fan Trap: Uso de Window Functions (ROW_NUMBER) para desduplicar pagamentos (relação 1:N) e permitir JOINs corretos com itens de pedido, evitando a multiplicação de valores.
   - Data Masking: Anonimização de dados sensíveis de clientes (LGPD) diretamente na view.
   - Enriquecimento: Tratamento de strings e geolocalização.
- **Power BI & DAX:**
   - Modelagem dimensional (Star Schema / Snowflake).
   - Cálculos estatísticos avançados (Regressão Linear, LIFT, Percentis).
   - Design de Interface (UI/UX) com Navegação e Dark Mode.
   ![Modelo Dimensional](docs/images/model.png)  
   *Modelo Dimensional: Modelagem Dimensional Power BI*  

### 1. Configuração do Ambiente (Infrastructure)
O objetivo desta etapa foi criar um ambiente de dados isolado (Sandbox) utilizando Docker, garantindo que o banco de dados PostgreSQL possa ser instanciado em qualquer máquina sem dependências locais complexas. 

**1.1 Banco de Dados (Docker Compose)**  
Arquivo de orquestração do container.

**Arquivo:** ```docker-compose.yml```
```bash
services:
  # Database Service Postgres
  db:
    image: postgres:15
    container_name: postgres_olist_db
    environment:
      - POSTGRES_USER=admin_olist
      - POSTGRES_PASSWORD=${DB_PASSWORD} # Variável de ambiente para segurança
      - POSTGRES_DB=bi_comercial_db
    ports:
      - "5432:5432"
    volumes:
      - bi_comercial_data:/var/lib/postgresql/data

volumes:
  bi_comercial_data:
```

**1.2 Segurança e Credenciais**  
Arquivo de orquestração do container.

**Arquivo:** ```.env```
```bash
# Configuração de Conexão com o Banco
DATABASE_URL="postgresql://admin_olist:sua_senha_forte@localhost:5432/olist_db"
```

### 2. Extração e Carga (Python ETL)
Script desenvolvido para automatizar a ingestão dos dados brutos (CSV) para o Data Warehouse.

**2.1 Gerenciador de Conexão**  
Módulo responsável por ler o ```.env``` e criar a conexão segura com o banco.

**Arquivo:** ```scripts/database.py```

**2.2 Pipeline de Ingestão (Extract & Load)**  
Script principal que varre a pasta de dados, normaliza os arquivos e carrega no PostgreSQL.

Arquivo: ```scripts/load_data.py```

### 3. Transformação (SQL Views)
Nesta etapa, utilizamos SQL para criar a camada Trusted/Gold. As transformações incluem limpeza de dados, resolução de problemas de granularidade e regras de negócio.

**3.1 Dimensão Clientes (v_dim_customers)**  
Aplica regras de anonimização (LGPD) e padronização de texto.

**Arquivo:** ```sql/v_dim_customers.sql```

**3.2 Dimensão Geolocalização (v_dim_geolocation)**  
Resolve o problema de duplicidade de coordenadas por CEP e enriquece com o nome do estado.

**Arquivo:** ```sql/v_dim_geolocation.sql```

**3.3 Dimensão Produtos (v_dim_products)**  
Padroniza os nomes das categorias (Title Case) e trata valores nulos.

**Arquivo:** ```sql/v_dim_products.sql```

**3.4 Dimensão Pagamentos (v_dim_payments)**  
Criação de uma dimensão auxiliar a partir dos fatos para tradução e ordenação personalizada dos métodos de pagamento.

**Arquivo:** ```sql/v_dim_payments.sql```

**3.5 Tabela Fato (v_fact_order_items)**  
Tabela central do Star Schema. Resolve o problema de "Fan Trap" (multiplicação de linhas) causado pela relação 1:N entre Pedidos e Pagamentos.

**Arquivo:** ```sql/v_fact_order_items.sql```

### 4. Inteligência de Negócio (DAX)
Abaixo estão os códigos completos das medidas desenvolvidas para as análises avançadas no Power BI.

**4.1 KPIs Financeiros e Temporais**  
**Valor Bruto Total**
```
Valor Bruto Total = 

/* ==========================================================================
Medida: Valor Bruto Total (Gross Revenue / GMV)
==========================================================================
Descrição de Negócio:
    Representa o Faturamento Bruto total da empresa.
    É a soma do valor monetário de todos os itens vendidos.

Nota Técnica (Iteradores):
    Utiliza a função SUMX (Iteradora) em vez de uma multiplicação simples
    de colunas agregadas.
    
    Lógica: A função percorre a tabela fato 'linha a linha', multiplica 
    (Preço * Quantidade) naquele contexto específico e só depois soma os resultados.
    Isso garante a precisão matemática mesmo se a granularidade mudar no futuro 
    (ex: um item com quantidade > 1).

Dependência de Arquitetura:
    Esta medida assume que pedidos cancelados ou com preço nulo já foram 
    filtrados na camada de transformação SQL (v_fact_order_items), 
    garantindo performance máxima no DAX.
*/
SUMX(
    'public v_fact_order_itens',
    'public v_fact_order_itens'[quantity] * 'public v_fact_order_itens'[price]
)
```
**Total de Pedidos**
````
Total de Pedidos = 
/* ==========================================================================
Medida: Total de Pedidos (Order Volume)
==========================================================================
Descrição de Negócio:
    Contagem distinta de transações de venda (checkouts) realizadas.
    Esta métrica representa o tráfego de vendas, independentemente do tamanho
    da cesta (número de itens) de cada compra.

Nota Técnica (Granularidade):
    A tabela fato (v_fact_order_items) possui granularidade no nível do ITEM.
    Isso significa que um pedido com 3 produtos gera 3 linhas com o mesmo OrderID.
    
    Utiliza DISTINCTCOUNT para desduplicar essas ocorrências e obter o 
    número real de pedidos únicos (Cabeçalhos de Pedido), garantindo a 
    precisão da contagem.
*/
DISTINCTCOUNT('public v_fact_order_itens'[order_id])
````
**Quantidade Total**  
````
Quantidade Total = 
/* = =========================================================================
Medida: Quantidade Total
==========================================================================
Descrição de Negócio:
    Representa o volume físico total de itens comercializados no período.
    É uma medida base (Base Measure) utilizada para compor KPIs mais 
    complexos como "Ticket Médio" e "Itens por Cesta".

Nota Técnica (Arquitetura):
    A coluna [quantity] não existia na fonte original. Ela foi engenheirada 
    na View SQL (v_fact_order_items) com valor fixo '1' para cada linha.
    Isso transforma uma operação de contagem (COUNTROWS) em uma operação 
    de soma (SUM), que é mais performática e flexível em agregações do VertiPaq.
*/

SUM('public v_fact_order_itens'[quantity])
````
**Valor Bruto PY**  
````
Valor Bruto PY = 
/* ==========================================================================
Medida: Valor Bruto PY (Previous Year Revenue)
==========================================================================
Descrição de Negócio:
    Calcula o Faturamento Bruto do mesmo período no ano anterior.
    
    Esta métrica é fundamental para isolar o efeito da Sazonalidade.
    No varejo, permite comparar "maçãs com maçãs" (ex: Black Friday deste ano
    contra Black Friday do ano passado), servindo de base para o cálculo
    de Crescimento (YoY %).

Nota Técnica (Context Transition):
    A função CALCULATE modifica o contexto de filtro original.
    A função SAMEPERIODLASTYEAR retorna um conjunto de datas deslocado
    exatamente um ano para trás em relação ao contexto atual.
    
    Exemplo: Se o filtro visual é "Março 2018", a medida calcula a soma
    das vendas ocorridas em "Março 2017".
*/
CALCULATE(
    [Valor Bruto Total],
    SAMEPERIODLASTYEAR(dCalendar[Data])
)
````
**Valor Bruto YoY %**
```
Valor Bruto YoY % = 
/* ==========================================================================
Medida: Valor Bruto YoY % (Year-over-Year Growth)
==========================================================================
Descrição de Negócio:
    Calcula a taxa de crescimento (ou retração) percentual das vendas em
    relação ao mesmo período do ano anterior.
    
    É o principal KPI de "Velocidade" do negócio. Um número positivo indica
    expansão real, descontando o efeito da sazonalidade natural do varejo.

Nota Técnica (Safe Division & Variables):
    1. Variáveis (VAR): Utiliza variáveis para tornar a lógica de cálculo
       (Atual - Anterior) explícita e legível antes da divisão.
    
    2. Função DIVIDE: A utilização da função DIVIDE é mandatória em produção
       ao invés do operador matemático simples (/).
       
       Motivo: A função DIVIDE trata automaticamente cenários de "Divisão por Zero"
       (comum quando não há histórico no ano anterior, ex: início da operação),
       retornando BLANK em vez de gerar erros de "Infinity" que quebrariam o visual.
*/
VAR valor_atual = [Valor Bruto Total]
VAR valor_anterior = [Valor Bruto PY]
VAR crescimento = valor_atual - valor_anterior

RETURN
DIVIDE(
    crescimento,
    valor_anterior
)
```
**Valor Bruto (Visual Cortado)**
````
Valor Bruto (Visual Cortado) = 
/* ==========================================================================
Medida: Valor Bruto (Visual Cortado) - [Data Viz Helper]
==========================================================================
Descrição de Negócio:
    Variação da medida de Faturamento Bruto projetada especificamente para
    gráficos de tendência temporal.
    
    Esta medida aplica um "Corte Manual" (Hard Cut) em Agosto de 2018.
    Motivo: O dataset original (Olist) possui dados incompletos/parciais nos
    últimos meses, o que gerava uma queda artificial ("Cliff Effect") nos 
    gráficos, distorcendo a percepção de tendência do usuário.

Nota Técnica (BLANK vs ZERO em Gráficos):
    Utilizamos a função BLANK() intencionalmente quando a data ultrapassa
    o corte.
    
    Comportamento no Power BI:
    - Retornar 0: O gráfico desenharia uma linha despencando até o eixo.
    - Retornar BLANK: O gráfico interrompe a plotagem da linha naquele ponto.
    
    Isso permite comparar o Real (que para em Agosto) com a Projeção 
    (que continua até Dezembro) sem poluição visual.
*/
VAR DataCorte = DATE(2018, 8, 1) -- Data limite da integridade dos dados

RETURN
IF(
    MAX(dCalendar[data]) < DataCorte,
    [Valor Bruto Total],
    BLANK() -- Interrompe a linha visualmente
)
````

**4.2 Análise de Cesta de Compras (Cross-Sell)**  
**Total Pedidos Categoria (Linha)**
````
Total Pedidos Categoria (Linha) = 
/* ==========================================================================
Medida: Total Pedidos Categoria (Linha) - [Denominador da Probabilidade]
==========================================================================
Descrição de Negócio:
    Calcula o volume total de vendas da "Categoria Âncora" (Produto X) 
    selecionada pelo usuário.
    
    Esta medida serve como o denominador fixo para o cálculo da Probabilidade 
    Condicional P(Y|X). Ela responde: "Quantas vezes o produto X foi vendido 
    no total?", independentemente de com qual produto Y estamos comparando.

Nota Técnica (Disconnected Tables & REMOVEFILTERS):
    Esta medida é projetada para funcionar dentro de uma matriz ou gráfico onde
    o eixo é uma Tabela Desconectada ('dim_products_columns').
    
    1. CALCULATE: Modifica o contexto de filtro.
    2. REMOVEFILTERS: Remove explicitamente qualquer filtro vindo da tabela
       'dim_products_columns'.
       
    Por que isso é necessário?
    Sem o REMOVEFILTERS, o contexto visual do gráfico filtraria a medida para
    mostrar apenas a intersecção (X e Y). Nós precisamos que esta medida
    retorne o Total de X constante em todas as barras para que a divisão
    (Intersecção / Total X) funcione matematicamente.
*/

CALCULATE(
    [Total de Pedidos],
    REMOVEFILTERS(dim_products_columns)
)
````
**Pedidos em Comum (Afinidade)**
````
Pedidos em Comum (Afinidade) = 
/* ==========================================================================
Medida: Pedidos em Comum (Afinidade) - [Market Basket Core]
==========================================================================
Descrição de Negócio:
    O motor do algoritmo de recomendação ("Quem comprou X, também levou Y").
    
    Esta medida calcula a intersecção de vendas entre dois produtos distintos
    dentro do mesmo carrinho (Order ID). É utilizada para identificar padrões
    de consumo e oportunidades de Cross-Sell.

Nota Técnica (Disconnected Tables & Set Theory):
    Implementa o padrão de "Tabelas Desconectadas" para permitir a comparação
    de duas dimensões idênticas (Produto A vs Produto B) sem propagação de filtro.

    Lógica do Algoritmo:
    1. Guard Clauses (Proteção): Usa HASONEVALUE para garantir que o cálculo
       só ocorra no nível de célula (Produto x Produto), economizando CPU nos totais.
       Também evita a "Diagonal" (comparar Produto A com ele mesmo).
    
    2. Virtual Relationships (TREATAS): Usa TREATAS para aplicar o filtro da
       tabela auxiliar ('dim_products_columns') na tabela fato apenas durante
       a execução desta medida.
       
    3. Teoria de Conjuntos (INTERSECT): Isola os IDs de pedidos que existem
       SIMULTANEAMENTE na Lista A e na Lista B.
       
    4. Ruído Estatístico: Retorna BLANK se a contagem for <= 1 para limpar
       o visual de associações acidentais irrelevantes.
*/

IF(
    HASONEVALUE('public v_dim_products'[product_category]) &&
    HASONEVALUE(dim_products_columns[product_category]) &&
    SELECTEDVALUE('public v_dim_products'[product_category]) <> SELECTEDVALUE(dim_products_columns[product_category]),

    -- 1. Conjunto A: Pedidos contendo o produto selecionado no filtro principal
    VAR pedidos_produto_linha = CALCULATETABLE(
        VALUES('public v_fact_order_itens'[order_id]),
        'public v_dim_products'
    )

    -- 2. Conjunto B: Pedidos contendo o produto do eixo comparativo
    -- Usa TREATAS para ativar o relacionamento virtual com a tabela desconectada
    VAR pedidos_produto_coluna = CALCULATETABLE(
        VALUES('public v_fact_order_itens'[order_id]),
        TREATAS(
            VALUES(dim_products_columns[product_category]),
            'public v_dim_products'[product_category]
        )
    )

    -- 3. Intersecção: Pedidos que existem em A E em B
    VAR contagem_pedidos_comuns = COUNTROWS(INTERSECT(pedidos_produto_linha, pedidos_produto_coluna))

    -- 4. Filtro de Ruído
    RETURN
    IF(contagem_pedidos_comuns > 1, contagem_pedidos_comuns, BLANK())
)
````
**Probabilidade (Y | X)**
````
Probabilidade (Y | X) = 
/* ==========================================================================
Medida: Probabilidade (Y | X) - [Conditional Probability]
==========================================================================
Descrição de Negócio:
    Calcula a probabilidade de um cliente comprar o Produto Y (Eixo do Gráfico),
    dado que ele já comprou o Produto X (Selecionado no Filtro).
    
    Também conhecida como "Confiança" (Confidence) em Mineração de Regras de 
    Associação. É o KPI que define a eficiência de uma recomendação de Cross-Sell.

Nota Técnica (Math & Context):
    Implementa a fórmula estatística P(B|A) = P(A ∩ B) / P(A).
    
    - Numerador: [Pedidos em Comum] (Intersecção).
    - Denominador: [Total Pedidos Categoria (Linha)] (Total do Antecedente).
    
    A função DIVIDE é utilizada para garantir a segurança do cálculo, retornando
    BLANK automaticamente caso o denominador seja zero (ex: categorias novas 
    sem histórico de vendas).
*/

DIVIDE(
    [Pedidos em Comum (Afinidade)],
    [Total Pedidos Categoria (Linha)]
)
````
**Lift (Alavancagem)**
````
Lift (Alavancagem) = 
/* ==========================================================================
Medida: Lift (Alavancagem) - [Statistical Strength]
==========================================================================
Descrição de Negócio:
    Métrica estatística que mede a força da associação entre dois produtos,
    isolando o "fator popularidade".
    
    Responde à pergunta: "A compra do Produto X aumenta ou diminui a chance
    real de comprar o Produto Y, comparado ao acaso?"
    
    Interpretação:
    - Lift > 1: Associação Positiva (X impulsiona Y).
    - Lift = 1: Neutro (Eventos independentes).
    - Lift < 1: Associação Negativa (Quem compra X evita Y).

Nota Técnica (Context Manipulation):
    Implementa a fórmula Bayesiana: Lift = P(Y|X) / P(Y).
    
    O desafio técnico é calcular P(Y) (Probabilidade Global) dentro de um 
    visual que já está filtrado por X.
    
    Solução DAX:
    1. REMOVEFILTERS: Remove o filtro da seleção atual (Produto X).
    2. TREATAS: Força o filtro do eixo do gráfico (Produto Y) na tabela fato
       para calcular sua performance isolada no site todo.
*/

-- 1. Probabilidade Condicional (Já calculada anteriormente)
VAR Prob_Condicional = [Probabilidade (Y | X)]

-- 2. Probabilidade Global de Y (Popularidade natural do produto Y)
VAR TotalPedidosSite = 
    CALCULATE(
        [Total de Pedidos], 
        REMOVEFILTERS() -- Remove todos os filtros para pegar o total geral do e-commerce
    )

VAR PedidosComY_Global = 
    CALCULATE(
        [Total de Pedidos],
        -- Remove o filtro da Categoria X (Esquerda) para não enviesar
        REMOVEFILTERS('public v_dim_products'), 
        -- Aplica o filtro da Categoria Y (Eixo do gráfico) na tabela fato
        TREATAS(VALUES(dim_products_columns[product_category]), 'public v_dim_products'[product_category])
    )

VAR Prob_Global = DIVIDE(PedidosComY_Global, TotalPedidosSite)

-- 3. O Cálculo do Lift
RETURN
    IF(
        Prob_Global > 0 && Prob_Condicional > 0,
        DIVIDE(Prob_Condicional, Prob_Global),
        BLANK()
    )
````

**4.3 CRM e Segmentação (RFM)**  
**Tabela Calculada: d_rfm**
````
d_rfm = 
/* ==========================================================================
Tabela Calculada: d_rfm - [Customer Segmentation Engine]
==========================================================================
Descrição de Negócio:
    Implementação do algoritmo clássico de segmentação RFM (Recência, Frequência, Valor).
    
    Objetivo: Classificar a base de clientes em clusters comportamentais para 
    estratégias de CRM (ex: Recuperação de Churn, Fidelização, Onboarding).
    
    Output: Uma tabela dimensão contendo um perfil único por cliente (Granularidade 1:1),
    com Scores de 1 a 5 e o Segmento Final (ex: "Campeões", "Em Risco").

Nota Técnica (Algorithm Design):
    1. Tratamento Temporal (Static Reference): 
       Como o dataset é histórico (encerrado em 2018), não utiliza a função TODAY().
       Fixa a data de referência no último pedido registrado para simular a análise
       no "tempo presente" da época, evitando que todos os clientes parecessem inativos.

    2. Agregação (Granularity Shift):
       Utiliza SUMMARIZE para reduzir a granularidade de "Transações" (Fato)
       para "Clientes Únicos" (Dimensão), calculando os KPIs base (Dias sem comprar, Qtd Pedidos, Total Gasto).

    3. Scoring Híbrido (Percentile vs. Heuristic):
       - Recência e Monetário: Usamos PERCENTILEX (Estatística) para dividir a base
         em quintis (Top 20% = Nota 5), garantindo distribuição justa.
       - Frequência: Devido à natureza do varejo esporádico da Olist (96% dos clientes 
         compraram apenas 1 vez), percentis não funcionariam. Aplicamos regras fixas 
         manuais (Heurística): 1 compra = Nota 1; >4 compras = Nota 5.
*/
VAR DataReferencia = MAX('public v_fact_order_itens'[order_purchase_timestamp]) -- Data do "Hoje" simulado

-- 1. Tabela Virtual: Agregação dos KPIs por Cliente
VAR TabelaBase = 
    SUMMARIZE(
        'public v_dim_customers',
        'public v_dim_customers'[customer_unique_id],
        "RecenciaDias", DATEDIFF(MAX('public v_fact_order_itens'[order_purchase_timestamp]), DataReferencia, DAY),
        "Frequencia", DISTINCTCOUNT('public v_fact_order_itens'[order_id]),
        "Monetario", SUM('public v_fact_order_itens'[price])
    )

-- 2. Scoring: Atribuição de Notas (1 a 5)
VAR TabelaComScores = 
    ADDCOLUMNS(
        TabelaBase,
        "R_Score", 
            VAR R_Pontos = [RecenciaDias]
            RETURN SWITCH(TRUE(),
                -- Menor Recência = Maior Nota (Inversamente Proporcional)
                R_Pontos <= PERCENTILEX.INC(TabelaBase, [RecenciaDias], 0.2), 5, -- Top 20% mais recentes
                R_Pontos <= PERCENTILEX.INC(TabelaBase, [RecenciaDias], 0.4), 4,
                R_Pontos <= PERCENTILEX.INC(TabelaBase, [RecenciaDias], 0.6), 3,
                R_Pontos <= PERCENTILEX.INC(TabelaBase, [RecenciaDias], 0.8), 2,
                1 -- Cauda longa de inativos
            ),
        "F_Score", 
            -- Regra Manual para lidar com baixa recorrência do marketplace
            SWITCH(TRUE(),
                [Frequencia] >= 4, 5,
                [Frequencia] = 3, 4,
                [Frequencia] = 2, 3,
                TRUE(), 1
            ),
        "M_Score", 
            VAR M_Pontos = [Monetario]
            RETURN SWITCH(TRUE(),
                -- Maior Valor = Maior Nota (Diretamente Proporcional)
                M_Pontos >= PERCENTILEX.INC(TabelaBase, [Monetario], 0.8), 5, -- Top 20% maiores gastos
                M_Pontos >= PERCENTILEX.INC(TabelaBase, [Monetario], 0.6), 4,
                M_Pontos >= PERCENTILEX.INC(TabelaBase, [Monetario], 0.4), 3,
                M_Pontos >= PERCENTILEX.INC(TabelaBase, [Monetario], 0.2), 2,
                1 
            )
    )

-- 3. Segmentação Final: Clusterização baseada nos Scores
RETURN
    ADDCOLUMNS(
        TabelaComScores,
        "Segmento RFM", 
        SWITCH(TRUE(),
            [R_Score] >= 4 && [F_Score] + [M_Score] >= 8, "Campeões",    -- A Elite (Recente + Gasta Muito)
            [R_Score] >= 3 && [F_Score] >= 3, "Leais",                   -- Base de sustentação
            [R_Score] >= 3, "Novos Clientes",                            -- Recentes (ainda sem frequência alta)
            [R_Score] <= 2 && [M_Score] >= 4, "Em Risco (VIPs)",         -- ALERTA: Gastava muito e sumiu
            [R_Score] <= 2, "Hibernando/Perdidos",                       -- Inativos de baixo valor
            "Outros"
        )
    )
````
**Taxa de Recompra Global**
````
Taxa de Recompra Global = 
/* ==========================================================================
Medida: Taxa de Recompra Global - [Retention KPI]
==========================================================================
Descrição de Negócio:
    Percentual da base de clientes que realizou mais de uma compra na história.
    
    No contexto de marketplace (Olist), esta métrica tende a ser baixa, o que
    evidencia o desafio de fidelização. Um aumento nesta taxa impacta 
    diretamente o LTV (Lifetime Value) e reduz a dependência de aquisição
    paga (CAC).

Nota Técnica (Filter Context):
    Utiliza a tabela dimensão 'd_rfm' (Calculada) como base.
    
    - Numerador: Filtra clientes onde a coluna [Frequencia] > 1.
    - Denominador: Total de clientes distintos.
    
    A simplicidade desta medida esconde a complexidade da tabela d_rfm, que já
    pré-calculou a frequência de cada cliente único no SQL/DAX.
*/
VAR ClientesComMaisDeUmaCompra = 
    CALCULATE(
        COUNTROWS('d_rfm'),
        'd_rfm'[Frequencia] > 1
    )
VAR TotalClientes = COUNTROWS('d_rfm')

RETURN
    DIVIDE(ClientesComMaisDeUmaCompra, TotalClientes)
````
**Taxa de Retenção (Ativos)**
````
Taxa de Retenção (Ativos) = 
/* ==========================================================================
Medida: Taxa de Retenção (Ativos) - [Base Health]
==========================================================================
Descrição de Negócio:
    Mede a proporção de clientes considerados "Vivos" ou "Ativos" em relação
    ao total histórico de cadastros.
    
    Diferente do Churn tradicional (baseado em cancelamento de contrato),
    no varejo definimos "Ativo" com base no comportamento recente (Recência)
    e valor (Monetário).
    
    Segmentos considerados Ativos:
    - Campeões, Leais, Novos, Promissores e até os Em Risco (que ainda
      estão no radar de recuperação).
    
    Segmentos considerados Churn (Perdidos):
    - Hibernando/Perdidos.

Nota Técnica (Set Filtering):
    Utiliza o operador IN para filtrar múltiplos segmentos de texto de uma vez,
    simplificando a sintaxe em comparação com múltiplos OR().
*/
VAR ClientesAtivos = 
    CALCULATE(
        COUNTROWS('d_rfm'), 
        'd_rfm'[Segmento RFM] IN {"Campeões", "Leais", "Novos Promissores", "Novos", "Em Risco (VIPs)"}
    )
VAR TotalClientes = COUNTROWS('d_rfm')

RETURN
    DIVIDE(ClientesAtivos, TotalClientes)
````
**Total Clientes em Risco**
````
Total Clientes em Risco = 
/* ==========================================================================
Medida: Total Clientes em Risco - [Churn Alert KPI]
==========================================================================
Descrição de Negócio:
    Contagem de clientes classificados no segmento "Em Risco (VIPs)".
    
    Quem são eles? Clientes que possuem alto Score Monetário (gastaram muito
    no passado), mas baixo Score de Recência (não compram há muito tempo).
    
    Esta é a métrica mais crítica para o time de CRM, pois representa
    o "Churn de Alto Valor". Recuperar um cliente deste grupo é estatisticamente
    mais barato e rentável do que adquirir novos clientes frios.

Nota Técnica (Segmentation Filter):
    Utiliza a tabela calculada 'd_rfm' como base.
    
    A função CALCULATE aplica um filtro explícito sobre a coluna [Segmento RFM],
    isolando apenas o cluster "Em Risco (VIPs)".
    
    Obs: Utilizamos DISTINCTCOUNT no ID único para garantir precisão, embora
    na tabela d_rfm a granularidade já seja de 1 linha por cliente.
*/

CALCULATE(
    DISTINCTCOUNT('d_rfm'[customer_unique_id]), 
    'd_rfm'[Segmento RFM] = "Em Risco (VIPs)"
)
````

**4.4 Análise Preditiva (Regressão Linear)**  
**Vendas (Regressão Linear)**  
````
Vendas (Regressão Linear) = 
/* ==========================================================================
Medida: Vendas (Regressão Linear) - [Predictive Analytics]
==========================================================================
Descrição de Negócio:
    Modelo estatístico preditivo que traça a linha de tendência matemática
    das vendas ($y = mx + b$).
    
    Objetivo: Identificar se a tendência estrutural do negócio é de crescimento
    ou queda, ignorando a volatilidade diária. Além disso, projeta essa 
    tendência para o futuro (Forecasting), servindo de base para metas.

Nota Técnica (Statistical DAX):
    Implementação manual do "Método dos Mínimos Quadrados" (Ordinary Least Squares).
    
    1. Training Set (Conjunto de Treino):
       Definir uma 'DataCorte' (01/08/2018) para isolar os dados históricos
       confiáveis. O algoritmo aprende a inclinação (Slope) usando apenas 
       dados anteriores a esta data, evitando que a queda de dados no final 
       do dataset (Set/Out) contamine a projeção.
       
    2. Cálculo dos Coeficientes:
       - Slope (m): A inclinação da reta (Taxa de crescimento diário).
       - Intercept (b): O ponto onde a reta cruza o eixo Y.
       
    3. Projeção (Forecasting):
       Aplica a fórmula linear (y = mx + b) para todo o contexto de data,
       incluindo o futuro. Isso permite que a linha continue sendo desenhada
       mesmo onde não há vendas reais.
*/
VAR DataCorte = DATE(2018, 8, 1) -- Limite do conjunto de treino

-- 1. Definição do Conjunto de Treino (Training Set)
VAR TabelaDados = 
    FILTER(
        ALL('dCalendar'),
        'dCalendar'[Data] < DataCorte &&
        NOT(ISBLANK([Valor Bruto Total]))
    )

-- 2. Estatística Descritiva (Inputs da Fórmula)
VAR Count_N = COUNTROWS(TabelaDados)
VAR Sum_X   = SUMX(TabelaDados, CONVERT('dCalendar'[Data], INTEGER)) -- X = Tempo
VAR Sum_Y   = SUMX(TabelaDados, [Valor Bruto Total])                  -- Y = Vendas
VAR Sum_XY  = SUMX(TabelaDados, CONVERT('dCalendar'[Data], INTEGER) * [Valor Bruto Total])
VAR Sum_X2  = SUMX(TabelaDados, CONVERT('dCalendar'[Data], INTEGER) ^ 2)

-- 3. Cálculo dos Coeficientes (Slope e Intercept)
VAR Slope = 
    DIVIDE(
        (Count_N * Sum_XY) - (Sum_X * Sum_Y),
        (Count_N * Sum_X2) - (Sum_X ^ 2)
    )

VAR Intercept = 
    DIVIDE(
        Sum_Y - (Slope * Sum_X),
        Count_N
    )

-- 4. Aplicação do Modelo (y = mx + b)
-- Converte a data atual do gráfico em número para aplicar na fórmula
VAR X_Atual = CONVERT(MAX('dCalendar'[Data]), INTEGER)

RETURN
    (Slope * X_Atual) + Intercept
````
**Vendas Média Móvel**
````
Vendas Média Móvel = 
/* ==========================================================================
Medida: Vendas Média Móvel - [Trend Smoothing & Dynamic Viz]
==========================================================================
Descrição de Negócio:
    Calcula a média móvel das vendas em uma janela de tempo dinâmica (ex: 7, 30 dias),
    definida pelo usuário através de um parâmetro de simulação ("What-If").
    
    Objetivo: Suavizar a volatilidade diária (ruído) para revelar a tendência real
    de crescimento ou queda do faturamento a médio prazo.

Nota Técnica (Time Intelligence & Visual Engineering):
    1. Parametrização: A variável 'Janela' captura o input do usuário, tornando
       a medida interativa (não é um cálculo estático de 7 dias).
    
    2. Janela Deslizante: Utiliza DATESINPERIOD com offset negativo para criar
       o intervalo de datas (Data Atual - Janela).
       
    3. Tratamento Visual (Data Cut):
       Aplica a mesma lógica de "Corte Rígido" (Hard Cut) em Agosto/2018.
       Se não fizéssemos isso, a média móvel começaria a incorporar os dias
       com valor zero (Setembro/Outubro), fazendo a linha verde cair artificialmente
       e distorcendo a leitura de tendência. Retornar BLANK() corta a linha.
*/
VAR Janela = 'Janela de Média'[Janela de Média Value]
VAR DataCorte = DATE(2018, 8, 1) -- Limite dos dados confiáveis
VAR DataAtual = MAX(dCalendar[Data])

RETURN
IF(
    DataAtual < DataCorte,
    
    -- Cálculo da Média na Janela Dinâmica
    CALCULATE(
        AVERAGEX(dCalendar, [Valor Bruto Total]),
        DATESINPERIOD(dCalendar[data], DataAtual, -Janela, DAY)
    ),
    
    BLANK() -- Interrompe a plotagem visualmente
)
````
**Vendas Projetadas (Cenário)**,
````
Vendas Projetadas (Cenário) = 
/* ==========================================================================
Medida: Vendas Projetadas (Cenário) - [What-If Simulation]
==========================================================================
Descrição de Negócio:
    Calcula o cenário de vendas futuras aplicando uma taxa de crescimento 
    (ou retração) definida pelo usuário sobre a tendência estatística atual.
    
    Objetivo: Permitir que gestores definam metas e simulem cenários estratégicos.
    Responde à pergunta: "Se performarmos 10% acima da nossa tendência natural,
    qual será o nosso faturamento em Dezembro?"

Nota Técnica (Measure Branching & Parameters):
    Esta medida combina dois conceitos avançados:
    
    1. Parâmetro What-If: Captura o valor selecionado no Slicer 'Crescimento Esperado %'
       (ex: 0.10 para 10%).
       
    2. Base de Tendência: Utiliza a medida [Vendas (Regressão Linear)] como base,
       e não as vendas do ano anterior.
       
       Por que usar a Regressão? 
       Para empresas em hipercrescimento (como a Olist em 2017/2018), usar o ano
       anterior como base gera metas irreais ou muito baixas. A Regressão Linear
       projeta o "Caminho Natural" (Inércia), e o cenário projeta o "Caminho da Meta"
       (Esforço).
*/


VAR TaxaCrescimento = 'Crescimento Esperado %'[Crescimento Esperado % Value]
VAR BaseTendencia = [Vendas (Regressão Linear)] -- A linha de tendência estatística

-- Projeta: Tendência Matemática * (1 + Fator de Crescimento)
RETURN
    BaseTendencia * (1 + TaxaCrescimento)
````

---

## 📊 Funcionalidades e Análises (Deep Dive)

**1. Visão Executiva de Vendas**  
Monitoramento de KPIs financeiros com comparação temporal.
- **Destaque:** Análise de Sazonalidade e Crescimento Ano-contra-Ano (YoY).
- **Engenharia:** Medidas de Time Intelligence (TOTALYTD, SAMEPERIODLASTYEAR) aplicadas sobre uma dimensão de calendário robusta.

**2. Motor de Recomendação (Cross-Sell)**  
Análise de Market Basket para identificar oportunidades de venda cruzada.
- **UX Guiada:** Interface onde o usuário seleciona um produto e recebe recomendações visuais imediatas com ícones dinâmicos.
- **Algoritmo:** Utiliza lógica de Teoria de Conjuntos (INTERSECT) e cálculo de LIFT (Alavancagem) para identificar associações estatisticamente relevantes, ignorando o ruído de produtos meramente populares.

3. **CRM e Segmentação de Clientes (RFM)**  
Clusterização da base de clientes utilizando a metodologia RFM (Recência, Frequência, Valor).
- **Algoritmo DAX:** Desenvolvido do zero (sem scripts externos) utilizando Percentis Estatísticos (PERCENTILEX.INC) para classificar clientes dinamicamente em clusters como "Campeões", "Leais", "Novos" e "Em Risco".
- **Visualização:** Scatter Plot com escala logarítmica para visualizar a cauda longa de clientes e identificar oportunidades de recuperação.

**4. Laboratório de Previsão (Análise Preditiva)**   
Página dedicada a Data Science e Simulação de Metas.
- **Regressão Linear (OLS):** Implementação manual do "Método dos Mínimos Quadrados" em DAX para traçar a tendência matemática de crescimento ($y = mx + b$), separando conjunto de treino e teste.
- **Simulador de Cenários (What-If):** Permite que diretores simulem metas ("E se crescermos 10% sobre a tendência?") e vejam o impacto financeiro projetado em tempo real.

---

## 🧠 Snippets de Código

Exemplos da lógica aplicada no projeto para demonstrar a profundidade técnica.  

**Python: Ingestão Resiliente**  
Trecho do script de carga que normaliza colunas e gerencia conexões seguras.
```python
# load_data.py
def load_csvs_to_postgres():
    # ...
    df = pd.read_csv(file_path)
    # Normalização de nomes para padrão SQL (snake_case)
    df.columns = [col.lower().strip() for col in df.columns]
    df.to_sql(table_name, engine, if_exists='replace', index=False)
```

**SQL: Resolução de Fan Trap (Granularidade Mista)**  
Uso de Window Functions para desduplicar pagamentos e permitir JOINs corretos.
```sql
-- v_fact_order_items.sql
WITH payments AS (
    SELECT 
        order_id, payment_type,
        -- Elege o pagamento principal pelo maior valor para evitar produto cartesiano
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY payment_value DESC) as rn
    FROM olist_order_payments
)
-- ... JOIN payments WHERE rn = 1
```

**DAX: Regressão Linear (Estatística Pura)**  
Cálculo estatístico manual para projeção de tendências futuras sem dependência de Python/R.
```
Vendas (Regressão Linear) = 
-- Split Treino/Teste para garantir integridade da projeção
VAR DataCorte = DATE(2018, 8, 1) 
VAR TabelaTreino = FILTER(ALL('dCalendar'), 'dCalendar'[Data] < DataCorte)

-- Cálculo dos Coeficientes (Slope e Intercept)
VAR Slope = DIVIDE( (Count_N * Sum_XY) - (Sum_X * Sum_Y), (Count_N * Sum_X2) - (Sum_X ^ 2) )
VAR Intercept = DIVIDE( Sum_Y - (Slope * Sum_X), Count_N )

-- Aplicação da Fórmula Linear (Forecasting)
RETURN (Slope * X_Atual) + Intercept
```

---

## 🚀 Como Executar este Projeto
**1. Clone o repositório:**
```bash
git clone https://github.com/LucianoAMagalhaes/BI_Comercial.git
```
**2. Suba o Banco de Dados (Docker):**
Garanta que o Docker esteja instalado e rode na raiz do projeto:
```bash
docker-compose up -d
```
**3. Carga de Dados:** Crie o ambiente virtual, instale as dependências e execute a carga:
```bash
python -m venv venv
source venv/bin/activate # ou venv\Scripts\activate no Windows
pip install -r requirements.txt
python -m scripts.load_data
```
**4. Acesse o Dashboard:** Abra o arquivo .pbip na pasta /power-bi e conecte ao seu banco de dados local.
- O arquivo .pbip está na pasta /power-bi. Basta abrir e conectar ao seu banco local.

---

## 📞 Contato
Gostou da análise? Vamos conversar sobre como dados podem transformar seu negócio.
- LinkedIn: [Luciano Magalhães](https://www.linkedin.com/in/lucianoamaro/)
- Email: lucianoamaro.m@gmail.com