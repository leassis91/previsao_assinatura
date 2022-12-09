# %%

# Standard Libraries
import pandas as pd
import sqlalchemy

# Metric Libraries
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.pipeline        import Pipeline
from sklearn                 import metrics

# Model Libraries
from sklearn.ensemble        import RandomForestClassifier

# Preprocessing Libraries
from feature_engine import imputation
from feature_engine import encoding

# FORMAT AND WARNINGS
import warnings
warnings.filterwarnings('ignore')
warnings.simplefilter(action='ignore', category=FutureWarning)

pd.set_option('display.max_columns', None)
pd.set_option('display.float_format', lambda x: '%.5f' % x)

# Helper Functions
def report_model(X, y, model, metric, is_prob=True):
    if is_prob:
        y_pred = model.predict_proba(X)[:, 1]
    else:
        y_pred = model.predict(X)
    res = metric(y, y_pred)
    return res

# %%
# 1.0 SAMPLE

print("Importando ABT...")
conn = sqlalchemy.create_engine("sqlite:///../../../data/gc.db")
df = pd.read_sql_table("tb_abt_sub_leassis", conn)
print("ok.")

## Nosso back test - Definição de uma base "Out-of-time"

print("Separando entre treinamento e backtest...")
df_oot = df[df['dtRef'].isin(['2022-01-15', '2022-01-16'])].copy()
df_train = df[~df['dtRef'].isin(['2022-01-15', '2022-01-16'])].copy()
print("Ok.")

features = df_train.columns[2:-1].tolist()
target = 'flagSub'


print("Separando entre Treino e Test...")
X_train, X_test, y_train, y_test = train_test_split(df_train[features], 
                                                    df_train[target],
                                                    random_state=42,
                                                    test_size=0.2)
print("Ok.")
# %%
# 2. EXPLORE
cat_features = X_train.dtypes[X_train.dtypes=='object'].index.tolist()
num_features = list(set(X_train.columns) - set(cat_features))

print("Estatística de missings...")
print("\t- Missing numerico:")
is_na = X_train[num_features].isna().sum()
print(is_na[is_na>0])
print('')
print("\t- Missing categorico:")
is_na_cat = X_train[cat_features].isna().sum()
print(is_na_cat[is_na_cat>0])
print("Ok.")

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
# 3. MODIFY

## 3.1 Imputação de Dados Faltantes
print("Construindo pipeline de ML...")
imput_1 = imputation.ArbitraryNumberImputer(arbitrary_number=-1, variables=missing_1)
### 3.2 One-Hot Encoding
onehot = encoding.OneHotEncoder(drop_last=True, variables=cat_features)
# %%
# 4. MODEL

rf_clf = RandomForestClassifier(n_estimators=200, 
                               min_samples_leaf=20,
                               random_state=42)



## 4.1 Definindo uma pipeline


params = {"n_estimators": [200, 500],
          "min_samples_leaf": [5, 10]
            }

gs = GridSearchCV(rf_clf, 
                  params,
                  cv=4,
                  n_jobs=-1, 
                  scoring='roc_auc',
                  refit=True)

pipe_rf = Pipeline(steps=[('Inputers', imput_1),
                             ('Encoders', onehot),
                             ('Model', gs)])
print("Ok.")

print("Encontrando o melhor modelo com GridSearch...")
pipe_rf.fit(X_train, y_train)
print("Ok.")

# %%

auc_train = report_model(X_train, y_train, pipe_rf, metrics.roc_auc_score)
auc_test = report_model(X_test, y_test, pipe_rf, metrics.roc_auc_score)
auc_oot = report_model(df_oot[features], df_oot[target], pipe_rf, metrics.roc_auc_score)

print("auc_train: ", auc_train)
print("auc_test: ", auc_test)
print("auc_oot: ", auc_oot)

# %%
print("Ajustar modelo para toda a base...")

pipe_model = Pipeline(steps=[('Inputers', imput_1),
                             ('Encoders', onehot),
                             ('Model', gs.best_estimator_)])

pipe_model.fit(df[features], df[target])
print("Ok.")

# %%

print("Feature Importances:\n")
ft = pipe_model[:-1].transform(df[features]).columns.tolist()
fi = pd.DataFrame(pipe_model[-1].feature_importances_, index=ft)
fi.sort_values(by=0, ascending=False)
print("Ok.")
# 

series_model = pd.Series({
    'model':pipe_model,
    'features':features,
    'auc_train':auc_train,
    'auc_test':auc_test,
    'auc_oot':auc_oot,
})

series_model.to_pickle("../../../models/modelo_subscription.pkl")

# %%
