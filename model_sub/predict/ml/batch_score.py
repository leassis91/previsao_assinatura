# %%
import argparse

import pandas as pd
import sqlalchemy

parser = argparse.ArgumentParser()
parser.add_argument("--date", "-d", default="max")
args = parser.parse_args()


print("Importando modelo...")
model = pd.read_pickle("../../../models/modelo_subscription.pkl")
print("Ok.")

print("Importando query...")
with open("../etl/query.sql", "r") as open_file:
    query = open_file.read()
    
print('Ok.')


 
print("Obtendo data para escoragem...")
conn = sqlalchemy.create_engine("sqlite:///../../../data/gc.db")

if args.date == "max":
    date = pd.read_sql("SELECT MAX(dtRef) as date FROM tb_book_players_leassis", conn)["date"][0]

else:
    date = args.date

print("Ok.")

print("Importando os dados...")
query = query.format(date=date)
df = pd.read_sql(query, conn)
print("Ok.")


print("Realizando os scores dos dados...")

df_score = df[['dtRef', 'idPlayer']].copy()
df_score['score'] = model['model'].predict_proba(df[model["features"]])[:, 1]
df_score['descModel'] = "Model Subscription"
df_score.head()
print("Ok.")

print("Enviando dados para o Banco de Dados...")
conn.execute(f"DELETE FROM tb_model_score_leassis WHERE dtRef = '{date}'")
df_score.to_sql("tb_model_score_leassis", conn, if_exists="append", index=False)
print("Ok.")
