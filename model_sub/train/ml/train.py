# %%

# Standard Libraries
from types import MethodWrapperType
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt
import seaborn as sns


# Metric Libraries
from sklearn.model_selection import train_test_split, GridSearchCV, RandomizedSearchCV
from sklearn.pipeline        import Pipeline
from sklearn                 import metrics

# Model Libraries
from sklearn.ensemble        import RandomForestClassifier, AdaBoostClassifier, GradientBoostingClassifier
from sklearn.tree            import DecisionTreeClassifier, ExtraTreeClassifier
from sklearn.linear_model    import LogisticRegressionCV



# Preprocessing Libraries
from feature_engine import imputation
from feature_engine import encoding
import scikitplot as skplt


# FORMAT AND WARNINGS
import warnings
warnings.filterwarnings('ignore')
warnings.simplefilter(action='ignore', category=FutureWarning)

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

rf_clf = RandomForestClassifier(n_estimators=200, 
                               min_samples_leaf=20,
                               random_state=42)

# ada_clf = AdaBoostClassifier(n_estimators=200,
#                              learning_rate=0.8,
#                              random_state=42)

# dt_clf = DecisionTreeClassifier(max_depth=15,
#                                 min_samples_leaf=20,
#                                 random_state=42)

# lr_clf = LogisticRegressionCV(cv=4, n_jobs=-1)


### 4.1 Definindo uma pipeline

params = {"n_estimators": [200, 300, 500],
          "min_samples_leaf": [5, 10, 20, 30]
            }

gs = GridSearchCV(rf_clf, 
                  params,
                  cv=4,
                  n_jobs=-1, 
                  scoring='roc_auc',
                  verbose=2,
                  refit=True)

pipe_rf = Pipeline(steps=[('Inputers', imput_1),
                             ('Encoders', onehot),
                             ('Model', gs)])

pipe_rf.fit(X_train, y_train)

cv_results = pd.DataFrame(gs.cv_results_).sort_values(by='rank_test_score')
# cv_results
# gs.best_params_

### Retiramos as pipelines, pois vimos que o RF é o melhor e não faz mais sentido utilizá-los

# pipe_ada = Pipeline(steps=[('Inputers', imput_1),
#                              ('Encoders', onehot),
#                              ('Model', ada_clf)])

# pipe_dt = Pipeline(steps=[('Inputers', imput_1),
#                              ('Encoders', onehot),
#                              ('Model', dt_clf)])

# pipe_lr = Pipeline(steps=[('Inputers', imput_1),
#                              ('Encoders', onehot),
#                              ('Model', lr_clf)])


# models = {"Random Forest":pipe_rf,
#           "AdaBoost":pipe_ada,
#           "Decision Tree": pipe_dt,
#           "Logistic Regression":pipe_lr}
# %%

def train_test_report(model, X_train, y_train, X_test, y_test, key_metric, is_prob=True):
    model.fit(X_train, y_train)
    pred = model.predict(X_test)
    prob = model.predict_proba(X_test)
    
    metric_result = key_metric(y_test, prob[:, 1]) if is_prob else key_metric(y_test, pred)
    return metric_result




# %%

gs.best_params_

## qual modelo tem mais acurácia

# for d, m in models.items():
#     result = train_test_report(m, X_train, y_train, X_test, y_test, metrics.roc_auc_score)
#     print(f"{d}: {result}")
    

# %%
## 5. Assess

y_train_pred = pipe_rf.predict(X_train)
y_train_prob = pipe_rf.predict_proba(X_train)

acc_train = round(100*metrics.accuracy_score(y_train, y_train_pred),2)
roc_train = metrics.roc_auc_score(y_train, y_train_prob[:, 1])
print("acc_train: ", acc_train)
print("roc_train: ", roc_train)

# %%

print("Baseline Treino: ", round(100*(1-y_train.mean()), 2))
print("Acurácia Treino: ", round(acc_train, 2))
# %%

y_test_pred = pipe_rf.predict(X_test)
y_test_prob = pipe_rf.predict_proba(X_test)

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
# AS CURVAS DE NEGÓCIO!

# PORCENTAGEM DA AMOSTRA QUE MOSTRA O QUÃO MELHOR É QUE A BASELINE
skplt.metrics.plot_lift_curve(y_test, y_test_prob)
plt.show()

# PORCENTAGEM DA AMOSTRA PARA ATINGIRMOS 100% DOS INTERESSADOS!
skplt.metrics.plot_cumulative_gain(y_test, y_test_prob)
plt.show()

# %%

X_oot, y_oot = df_oot[features], df_oot[target]

y_pred_oot = pipe_rf.predict(X_oot)
y_prob_oot = pipe_rf.predict_proba(X_oot)

acc_oot = metrics.accuracy_score(y_oot, y_pred_oot)
roc_oot = metrics.roc_auc_score(y_oot, y_prob_oot[:, 1])
print("acc_oot: ", acc_oot)
print("roc_oot: ", roc_oot)

print("Baseline oot: ", round(100*(1-y_oot.mean()), 2))
print("Acurácia oot: ", round(acc_oot, 2))



skplt.metrics.plot_lift_curve(y_oot, y_prob_oot)
plt.show()


skplt.metrics.plot_cumulative_gain(y_oot, y_prob_oot)
plt.show()

# %%

# EXPLICANDO PRO GERENTE DE NEGÓCIOS

## - Utilizando nosso modelo, temos o dobro de conversão em comparação a escolha aleatoria.
df_oot['prob'] = y_prob_oot[:, 1]

conv_model = df_oot.sort_values(by='prob', ascending=False) \
        .head(1000) \
        .mean()['prob']

conv_random = df_oot.sort_values(by='prob', ascending=False) \
      .mean()['prob']

total_model = df_oot.sort_values(by='prob', ascending=False) \
                    .head(1000) \
                    .sum()['prob']

total_sem = df_oot.sort_values(by='prob', ascending=False) \
                  .sum()['prob']
                  

print(f"Utilizando o modelo, ou seja, abordando as primeiras 1000 pessoas mais propensas:\n {total_model} ({100*conv_model:.2f}%)")
print(f"Sem segmentação, ou seja, tendo que ligar para toda a amostra de 2500 pessoas:\n {total_sem} ({100*conv_random:.2f}%)", )

# ou seja diminuimos o CAC (Custo de Aquisição do Cliente)

# Forma 1: Com nosso modelo, precisamos abordar apenas 40% do publico OU deixamos de abordar 60% dos clientes (1500 não interessados de 2518), para ter um ganho/convencer de 83% (117/140) do público potencial que podemos converter. 
# Forma 2: Deixamos de abordar 60% do público para deixar de trazer apenas 17% potenciais clientes. Evitamos custos desnecessários. Marketing e comunicação muito mais acurado.

# %%
features_model = pipe_rf[:-1].transform(X_train.head()).columns.tolist()

fs_importance = pd.DataFrame({"importance": pipe_rf[-1].feature_importances_,
                              "feature": features_model
                              })
fs_importance.sort_values(by='importance', ascending=False).head(20)