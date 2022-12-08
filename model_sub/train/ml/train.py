# %%

import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.ensemble        import RandomForestClassifier
from sklearn.pipeline        import Pipeline
from sklearn                 import metrics

from feature_engine import imputation
from feature_engine import encoding

import scikitplot as skplt


pd.set_option('display.max_columns', None)
pd.set_option('display.float_format', lambda x: '%.5f' % x)
# %%
# APLICANDO A METODOLOGIA 'SEMMA' - Sample, Explore, Modify, Model, Assess

## 1. SAMPLE
conn = sqlalchemy.create_engine("sqlite:///../../../data/gc.db")
df = pd.read_sql_table("tb_abt_sub_leassis", conn)

# Nosso back test - Definição de uma base "Out-of-time"
df_oot = df[df['dtRef'].isin(['2022-01-15', '2022-01-16'])].copy()
df_train = df[~df['dtRef'].isin(['2022-01-15', '2022-01-16'])].copy()

features = df_train.columns[2:-1].tolist()
target = 'flagSub'


X_train, X_test, y_train, y_test = train_test_split(df_train[features], 
                                                    df_train[target],
                                                    random_state=42,
                                                    test_size=0.2)


# %%
## 2. EXPLORE
cat_features = X_train.dtypes[X_train.dtypes=='object'].index.tolist()
num_features = list(set(X_train.columns) - set(cat_features))
print("Missing numerico:")
is_na = X_train[num_features].isna().sum()
print(is_na[is_na>0])
print('')
print("Missing categorico:")
is_na_cat = X_train[cat_features].isna().sum()
print(is_na_cat[is_na_cat>0])


missing_1 = ['winRateMirage',
             'winRateAncient',
             'vlIdade',
             'winRateTrain',
             'winRateDust2',
             'winRateVertigo',
             'winRateOverpass',
             'winRateInferno',
             'winRateNuke']

# %%
## 3. MODIFY

### 3.1 Imputação de Dados Faltantes
imput_1 = imputation.ArbitraryNumberImputer(arbitrary_number=-1, variables=missing_1)

### 3.2 One-Hot Encoding

onehot = encoding.OneHotEncoder(drop_last=True, variables=cat_features)


# %%
## 4. MODEL

model = RandomForestClassifier(n_estimators=200, 
                               min_samples_leaf=20,
                               n_jobs=-1)


### 4.1 Definindo uma pipeline

model_pipe = Pipeline(steps=[('Inputers', imput_1),
                             ('Encoders', onehot),
                             ('Model', model)
                                 ])

# %%

model_pipe.fit(X_train, y_train)

# %%

y_train_pred = model_pipe.predict(X_train)
y_train_prob = model_pipe.predict_proba(X_train)

acc_train = round(100*metrics.accuracy_score(y_train, y_train_pred),2)
roc_train = metrics.roc_auc_score(y_train, y_train_prob[:, 1])
print("acc_train: ", acc_train)
print("roc_train: ", roc_train)

# %%
## 5. Assess

print("Baseline Treino: ", round(100*(1-y_train.mean()), 2))
print("Acurácia Treino: ", round(acc_train, 2))
# %%

y_test_pred = model_pipe.predict(X_test)
y_test_prob = model_pipe.predict_proba(X_test)

acc_test = round(100*metrics.accuracy_score(y_test, y_test_pred), 2)
roc_test = metrics.roc_auc_score(y_test, y_test_prob[:, 1])
print("acc_test: ", acc_test)
print("roc_test: ", roc_test)

print("Baseline Teste: ", round(100*(1-y_test.mean()), 2))
print("Acurácia Teste: ", round(acc_test, 2))

# %%

skplt.metrics.plot_roc(y_test, y_test_prob)
plt.show()

# %%

skplt.metrics.plot_ks_statistic(y_test, y_test_prob)
plt.show()
# %%

skplt.metrics.plot_precision_recall(y_test, y_test_prob)
plt.show()
# %%

skplt.metrics.plot_lift_curve(y_test, y_test_prob)
plt.show()

# %%
features_model = model_pipe[:-1].transform(X_train.head()).columns.tolist()

fs_importance = pd.DataFrame({"importance": model_pipe[-1].feature_importances_,
                              "feature": features_model
                              })
fs_importance.sort_values(by='importance', ascending=False).head(20)