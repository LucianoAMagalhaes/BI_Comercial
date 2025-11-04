# Projeto 1: Análise de Cesta de Compras (Market Basket Analysis) - Varejo Olist

Este projeto de Business Intelligence analisa o comportamento de compra no e-commerce brasileiro, utilizando o dataset público da Olist. O objetivo é identificar padrões de consumo (produtos comprados juntos) para otimizar estratégias de cross-sell e gerenciamento de estoque.

**Dashboard Interativo (Link):** [INSIRA O LINK DO NOVYPRO/POWER BI SERVICE QUANDO ESTIVER PRONTO]

---

### 1. Problema de Negócio

Uma grande plataforma de e-commerce (marketplace) deseja aumentar seu ticket médio e otimizar seu inventário. Para isso, precisa responder às seguintes perguntas:

* Quais são os principais pares de produtos comprados juntos (cross-sell)?
* Se um cliente compra um "Produto X", qual a probabilidade de comprar o "Produto Y"?
* Como está o giro de estoque dos produtos "âncora" e seus "pares" frequentes?
* Qual o comportamento de vendas ao longo do tempo (Análise de Time Intelligence)?

---

### 2. Fonte dos Dados

* **[Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)**
* O dataset é composto por 9 arquivos .csv, contendo informações sobre pedidos, itens de pedido, clientes, pagamentos, geolocalização e produtos.
* Período de Análise: [PREENCHER DEPOIS - Ex: Set/2016 a Ago/2018]
* Volume de Dados: [PREENCHER DEPOIS - Ex: +100k pedidos]

---

### 3. Metodologia e Desafios Técnicos (ETL & Modelagem)

O maior desafio deste projeto foi transformar o conjunto de dados (pensado para OLTP - transacional) em um modelo analítico (OLAP - Star Schema).

* **ETL (Power Query):**
    * [PREENCHER DEPOIS - Ex: Limpeza de dados nulos nas tabelas X e Y.]
    * [PREENCHER DEPOIS - Ex: Merge das tabelas de itens de pedido e produtos.]
    * [PREENCHER DEPOIS - Ex: Criação da Dimensão dCliente unindo dados de 'olist_customers_dataset' e 'olist_geolocation_dataset'.]
* **Modelagem (Star Schema):**
    * O modelo foi construído com uma tabela Fato principal (`fItensPedido`) e X Dimensões (`dProduto`, `dCliente`, `dTempo`, `dLocalizacao`, `dPedido`).
    * *(Opcional: Insira aqui um print da sua tela de Modelo de Dados do Power BI)*

---

### 4. Análise e DAX (O Desafio)

Para responder às perguntas de negócio, foram criadas as seguintes métricas DAX avançadas:

* **Funções de Time Intelligence:**
    * `[Vendas YTD]` (Acumulado no Ano): `CALCULATE([Vendas], DATESYTD(dTempo[Date]))`
    * `[Vendas SPLY]` (Mesmo Período Ano Anterior): `CALCULATE([Vendas], SAMEPERIODLASTYEAR(dTempo[Date]))`
* **Análise de Cesta de Compras (Market Basket):**
    * [PREENCHER DEPOIS - Ex: Descrever a lógica DAX usada para encontrar produtos comprados juntos. Ex: "Uso de SUMMARIZE e CALCULATETABLE para identificar pares dentro do mesmo order_id."]

---

### 5. Principais Descobertas (Insights)

* **Insight 1:** [PREENCHER DEPOIS - Ex: Os produtos da categoria 'Cama, Mesa e Banho' são frequentemente comprados com 'Decoração'.]
* **Insight 2:** [PREENCHER DEPOIS - Ex: A probabilidade de comprar 'Produto Y' dado 'Produto X' é de 15%, sugerindo uma oportunidade de 'compre junto'.]
* **Insight 3:** [PREENCHER DEPOIS - Ex: O giro de estoque dos produtos 'Top 10 Pares' está 30% abaixo do ideal, indicando risco de ruptura.]

---

### 6. Ferramentas Utilizadas

* Power BI (Power Query, DAX, Visualização)
* GitHub (Versionamento e Documentação)