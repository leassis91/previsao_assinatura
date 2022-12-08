# Previsão de Assinaturas da Plataforma Gamers Club

## Dados

Para este projeto utilizaremos dados de partidas que ocorreram nos servidores da Gamers Club. São partidas referentes à 2.500 jogadores, havendo mais de 30 estatísticas de seus partidas. Tais como Abates, Assistências, Mortes, Flash Assist, Head Shot, etc.

Alem disso, temos informações de medalhas destes players, como:
- Assinatura Premium, Plus
- Medalhas da Comunidade

Para ter uma melhor descrição destes dados, confira na [página oficial do Kaggle](https://www.kaggle.com/gamersclub/brazilian-csgo-plataform-dataset-by-gamers-club) onde os dados foram disponibilizados.

Abaixo temos o schema (relacionamento) dos nossos dados.

<img src="https://user-images.githubusercontent.com/4283625/157664295-45b60786-92a4-478d-a044-478cdc6261d7.jpg" alt="" width="500">


## Rascunho

Caso sua equipe de marketing tente direcionar um mailing para qualquer tipo de pessoa, sem qualquer tipo de segmentação, sua equipe teria uma conversão de apenas 6% (baseline, df[target].mean() ). A partir do uso do modelo, podemos segmentarmos as primeiras 1.000 pessoas mais propensas a realizar uma assinatura. 
