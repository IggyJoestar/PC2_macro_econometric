'1. Importando las bases de datos
'-------------------------------------------------
'establece primero con cd

'credito en moneda extranjera
import "Credito ME.xlsx" range="Mensuales!B3:B401" na="#N/A" colhead=0 @freq M 1992 1 @smpl 1992M01 2025M03
rename series01 credito_me
'credito en moneda nacional
import "Credito MN.xlsx" range="Mensuales!B3:B401" na="#N/A" colhead=0 @freq M 1992 1 @smpl 1992M01 2025M03
rename series01 credito_mn

'Pbi
import "PBI (indice 2007=100).xlsx" range="Mensuales!B3:B376" na="#N/A" colhead=0 @freq M 1994 1 @smpl 1994M01 2025M02
rename series01 pbi

'tasa interbancaria moneda local
import "Tasa interbancaria MN.xlsx" range="Mensuales!B3:B356" na="#N/A" colhead=0 @freq M 1995 10 @smpl 1995M10 2025M03
rename series01 tasa_inter_mn
'tasa interbancaria moneda extranjera
import "Tasa interbancaria ME.xlsx" range="Mensuales!B3:B356" na="#N/A" colhead=0 @freq M 1995 10 @smpl 1995M10 2025M03
rename series01 tasa_inter_me



'2. haciendo logs a las series
'-------------------------------------------------
series log_pbi = log(pbi)
series log_credito_mn = log(credito_me)
series log_credito_me = log (credito_mn)

'3. Graficando las series
'-------------------------------------------------

graph log_pbi_line.line log_pbi
graph tasa_inter_mn_line.line tasa_inter_mn
graph tasa_inter_me_line.line tasa_inter_me
graph log_credito_mn_line.line log_credito_mn
graph log_credito_me_line.line log_credito_me

'4. Desestacionalizando
'------------------------------------------------
log_pbi.x12
log_credito_mn.x12
log_credito_me.x12
'tasa_inter_mn.x12
'tasa_inter_me.x12

'4. Comparando con el filtro x12
'------------------------------------------------
graph log_pbi_sa_line.line log_pbi_sa
graph log_credito_mn_sa_line.line log_credito_mn_sa
graph log_credito_me_sa_line.line log_credito_me_sa

'6.aplicando tests (se usan las ventanas)
'-------------------------------------------------
'al log_pbi

'al log_credito_mn_sa

'al log_credito_me_sa

'a tasa inter mn

'a tasa inter me

'7 Box J. checando los correlogramas
'-------------------------------------------------
log_pbi_sa.correl

tasa_inter_mn.correl

tasa_inter_me.correl
tasa_inter_me.correl(d=1)

log_credito_mn_sa.correl
log_credito_mn_sa.correl(d=1)

log_credito_me_sa.correl
log_credito_me_sa.correl(d=1)


'8. Modelos con Box J
'-----------------------------------------------
'para el pbi
ls log_pbi_sa c @trend ar(1)  ma(2) ma(3)
'para tasa inter mn
ls tasa_inter_mn c ar(1)
'---------
'credito mn sa
ls d(log_credito_mn_sa) c ar(1) ar(3)
'credito me sa
ls d(log_credito_me_sa) c ar(1) ar(2)
'para tasa inter me
ls d( tasa_inter_me) ma(2)


