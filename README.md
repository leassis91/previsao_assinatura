# Previsão de Assinaturas da Plataforma Gamers Club

Repositório destinado à criação de um modelo de Machine Learning com os dados da GC. A finalidade deste projeto é simular toda uma pipeline de um modelo real de negócios, desde a ingestão de dados por um banco de dados, até o deploy de um modelo na cloud com a entrega de um resultado consultado por um usuário. 

O objetivo final do modelo é simular a propensão de um cliente/jogador da plataforma Gamers Club se tornar um assinante pelos próximos 30 dias.

## Ferramentas

Durante o projeto, foram utilizadas algumas das seguintes bibliotecas:

- SQLalchemy
- Pandas
- Numpy
- Scikit-learn
- Feature-engine
- Scikit-plot

## Dados

Para este projeto utilizaremos dados de partidas que ocorreram nos servidores da Gamers Club. São partidas referentes A 2.500 jogadores, havendo mais de 30 estatísticas de seus partidas. Tais como Abates, Assistências, Mortes, Flash Assist, Head Shot, etc.

Além disso, temos informações de medalhas destes players, como:
- Assinatura Premium, Plus
- Medalhas da Comunidade

Para ter uma melhor descrição destes dados, confira na [página oficial do Kaggle](https://www.kaggle.com/gamersclub/brazilian-csgo-plataform-dataset-by-gamers-club) onde os dados foram disponibilizados.

Abaixo temos o schema (relacionamento) dos nossos dados.

<img src="https://user-images.githubusercontent.com/4283625/157664295-45b60786-92a4-478d-a044-478cdc6261d7.jpg" alt="" width="500">


## Book de Variáveis

Para uma melhor performance de nosso modelo, foi realizada a criação de um book de variáveis (feature store) e posteriormente criada a nossa variável resposta (target), ou seja, aquilo que queremos prever.

A variável resposta foi feita com base 


## ABT

## Modelagem SEMMA

Para realizar a pipeline de nosssa modelagem, foi adotada a metodologia SEMMA.

image.png



## Resolução de Negócios ao CEO

Caso sua equipe de marketing tente direcionar um mailing para qualquer tipo de pessoa, sem qualquer tipo de segmentação, ela teria uma conversão de apenas 6% (ou seja, média de conversão aleatória). A partir do uso do modelo, podemos segmentar as primeiras 1.000 pessoas mais propensas a realizar uma assinatura, e assim tendo o dobro de chances (11% de conversão) de converter um jogador a se tornar assinante.

- Forma 1: Com nosso modelo, precisamos abordar apenas 40% do publico OU deixamos de abordar 60% dos clientes (1500 não interessados de 2518), para ter um ganho/convencer de 83% (117/140) do público potencial que podemos converter.

- Forma 2: Deixamos de abordar 60% do público para deixar de trazer apenas 17% potenciais clientes. Evitamos custos desnecessários. Marketing e comunicação muito mais acurado.

image.png

## Deploy

Utilizamos a ferramenta de firefly para realizar um deploy local na máquina, onde executamos a query para consultar a data e o ID do player que queremos verificar a probabilidade de assinar.
Poderá ser realizado um deploy futuro em algum servidor da AWS, ou em alguma cloud como Heroku e Render.