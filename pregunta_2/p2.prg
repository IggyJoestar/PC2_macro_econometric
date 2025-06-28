'=== PREGUNTA 2A - Importar datos ===

cd "C:\Users\LENOVO\Downloads\Series de pbi y desempleo japon.xlsx"
smpl 1994Q1 2022Q4

' IMPORTAR ARCHIVO DE JAPÓN
import "Series de pbi y desempleo japon.xlsx" range="Sheet1" colhead=1

' Renombrar series importadas
copy JPNRGDPEXP JPNRGDPEXP_copy
rename JPNRGDPEXP_copy pbi_real
delete JPNRGDPEXP

copy LRUN64TTJPQ156S LRUN64TTJPQ156S_copy
rename LRUN64TTJPQ156S_copy tasa_desempleo
delete LRUN64TTJPQ156S

'=== GRAFICAR LAS SERIES EN NIVELES ===
graph g1.line pbi_real
graph g2.line tasa_desempleo
show g1 g2

'=== PREGUNTA 2B - Estacionariedad y logaritmos ===

series log_pbi_real = log(pbi_real)

' ADF TESTS
log_pbi_real.uroot(adf, exog=trend)
tasa_desempleo.uroot(adf, exog=trend)

'=== Diferencias para lograr estacionariedad ===
series dy = d(log_pbi_real)
series dt = d(tasa_desempleo)

'=== Estimación de VAR sin restricciones (VAR reducido) ===
var var_japan.ls 1 8 dy dt @ c

'=== Selección óptima de rezagos (hasta 13) ===
freeze(lag_select_japan) var_japan.laglen(13)

'=== Granger Causality entre variables ===
group g_japan dy dt
freeze(granger_test_japan) g_japan.cause(2)

'=== Impulso-Respuesta con descomposición Cholesky ===
freeze(chol_irfs) var_japan.impulse(24, m)
freeze(chol_fevd) var_japan.decomp(24) dy dt

'=== Reestimación del VAR con rezagos óptimos (ej. 2 si SC/HQ lo sugieren) ===
delete var_japan
var var_japan.ls 1 2 dy dt @ c

'=== MATRIZ DE RESTRICCIÓN DE LARGO PLAZO ===
matrix(2,2) lr_japan
lr_japan.fill(by=r) na,0,na,na

'=== Estimar el SVAR con restricción de Blanchard y Quah ===
var_japan.svar(rtype=patlr, lrname=lr_japan)

'=== IRFs estructurales con restricción de largo plazo ===
freeze(svar_irfs) var_japan.impulse(40, imp=struct, a, m)
show svar_irfs

'=== FEVD estructural con restricción de largo plazo ===
freeze(svar_fevd) var_japan.decomp(40, imp=struct) dy dt
show svar_fevd
