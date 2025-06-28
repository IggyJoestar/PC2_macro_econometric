'======================================================
'					      P3
'======================================================
'===== Cerrar todo y limpiar
close @all

'===== Establecer directorio de trabajo
cd "C:\Users\abrah\OneDrive\Documentos"

'===== Crear workfile
wfcreate(wf=PC4_p3_1) q 1994q01 2021q02

'===== Importar datos desde el nuevo archivo
import "C:\Users\abrah\OneDrive\Documentos\P3data.xlsx" colhead=1 na="#N/A" @freq Q 1994Q01 @smpl @all

'===== Graficar las series originales
for %a consumo pib
    freeze(graf_{%a}) {%a}.line
next


'Dado que las series son de frecuencia trimestral, es probable que muestren estacionalidad. 
'Desestacionalizamos con x.12

for %a %b consumo consumo pib pib

	{%a}.x12
	series ln{%b} = log({%a}_sa)
	
next

'Graficamos ambas series y analizamos tendencias comunes
for %a %b %c niveles consumo pib sa consumo_sa pib_sa logs lnconsumo lnpib

	group {%a} {%b} {%c}
	freeze(graf_{%a}) {%a}.line

next

freeze(graf_relacion) graf_niveles graf_sa graf_logs


' La gráfica sugiere una posible cointegración entre el PIB y el consumo (ambas crecen juntas con tendencia similar), pero se necesita aplicar pruebas econométricas para confirmarlo.

'b)
'******* ANÁLISIS DE COINTEGRACIÓN **********

'***** PASO 1: ANÁLISIS DE RAÍZ UNITARIA

'Tal y como se puede apreciar, ambas series muestran intercepto y tendencia. En tal sentido, se testeará raíz unitaria incluyendo ambos componentes. Asimismo, dado que nos encontramos en un escenario de posible no estacionariedad, el criterio de selección de rezagos para los test será el "Modified Akaike" (MAIC). Con el uso de este criterio preferimos sacrificar potencia a cambio de corregir definitivamente la autocorrelación.

	'Test de Raíz Unitaria
for %a lnconsumo lnpib
                      
		freeze(ur_adf_{%a}) {%a}.uroot(adf, info=maic, trend)
		freeze(ur_pp_{%a}) {%a}.uroot(pp, info=maic, trend)
		freeze(ur_gls_{%a}) {%a}.uroot(dfgls, info=maic, trend)
		freeze(ur_ers_{%a}) {%a}.uroot(ers, info=maic, trend)

	next
'A fin de mostrar todos los resultados de todos los test para ambas series, estos se juntarán en una sola tabla:

	'Creamos la tabla
	
		table(10,10) tabla_uroot
		tabla_uroot(2,1)="Ho: La serie tiene raíz unitaria."
		tabla_uroot(4,1)= "Variables 1/"
		tabla_uroot(4,2)= "ADF"
		tabla_uroot(4,3)= "PP"
		tabla_uroot(4,4)= "GLS"
		tabla_uroot(4,5)= "ERS"
		tabla_uroot(5,1)= "Estadistico al 5%"
		tabla_uroot(6,1)= "Consumo"
		tabla_uroot(7,1)= "PIB"
		tabla_uroot(9,1)= "1/ Se ha considerado el logaritmo de las series desestacionalizadas."

   'Llenamos la tabla
	
          setcell(tabla_uroot,5,2,ur_adf_lnconsumo(9,4))
		setcell(tabla_uroot,5,3,ur_pp_lnconsumo(9,4))
		setcell(tabla_uroot,5,4,ur_gls_lnconsumo(9,5))
		setcell(tabla_uroot,5,5,ur_ers_lnconsumo(11,5))

		for %a %1 lnconsumo 6 lnpib 7

			setcell(tabla_uroot,{%1},2,ur_adf_{%a}(7,4))
			setcell(tabla_uroot,{%1},3,ur_pp_{%a}(7,4))
			setcell(tabla_uroot,{%1},4,ur_gls_{%a}(7,5))
			setcell(tabla_uroot,{%1},5,ur_ers_{%a}(9,5))

		next

'******* PASO 2: ESTIMACIÓN POR MCO

'Estimamos por MCO y guardamos los residuos

equation mco.ls lnconsumo  lnpib
freeze(mco_1) mco.ls lnconsumo lnpib c @trend
mco.makeresid e

'Al observar el "output" de esta estimación se observan tres cosas que levantan sospechas: los estimadores parecen ser muy significativos, el R2 es muy cercano a 1 y el estadístico DW es menor a 1. Estos tres indicadores nos dicen que la estimación realizada es una regresión espúrea. Para concluir, será necesario analizar si el residuo de esta estimación es estacionario o no. Si es estacionario, se dice que existe una relación de cointegración entre las variables; caso contrario, es una relación espúrea.

series resid_prom = @mean(e)
group grupo_e e resid_prom
freeze(graph_resid) grupo_e.line

'En principio, el gráfico del residuo nos dice que a simple vista la serie parece ser estacionaria pues nunca se aleja de la muestra. Sin embargo, este es solo un primer análisis; es necesario hacer un test de coitegración.

'********** PASO 3: TEST DE COINTEGRACIÓN

''''''''''''''''' Trabajando con las series desestacionalizadas y en logs

'Metodología Engle y Granger

for %a none constant linear

freeze(test_{%a}_eg) logs.coint(method=eg, trend={%a},lagtype=maic)

next


table(30,30) tabla_test_coint

tabla_test_coint(2,1)="Método Engle y Granger"
tabla_test_coint(4,1)="Ho: Las series no están cointegradas"
tabla_test_coint(6,1)="Modelo sin componente determinístico"
tabla_test_coint(8,1)="Series"
tabla_test_coint(8,2)="p-value tau"
tabla_test_coint(8,3)="p-value z"
tabla_test_coint(9,1)="Consumo"
tabla_test_coint(10,1)="PIB"
tabla_test_coint(12,1)="Modelo con intercepto"
tabla_test_coint(14,1)="Series"
tabla_test_coint(14,2)="p-value tau"
tabla_test_coint(14,3)="p-value z"
tabla_test_coint(15,1)="Consumo"
tabla_test_coint(16,1)="PIB"
tabla_test_coint(18,1)="Modelo con intercepto y tendencia"
tabla_test_coint(20,1)="Series"
tabla_test_coint(20,2)="p-value tau"
tabla_test_coint(20,3)="p-value z"
tabla_test_coint(21,1)="Consumo"
tabla_test_coint(22,1)="PIB"



for %a %1 %2 %3 none 9 11 11 none 10 12 12 constant 15 12 12 constant 16 13 13 linear 21 12 12 linear 22 13 13

'Engle y Granger
	setcell(tabla_test_coint,{%1},2,test_{%a}_eg({%2},3),3)
	setcell(tabla_test_coint,{%1},3,test_{%a}_eg({%2},5),3)

next

'e)
'*********** PASO 4: ESTIMACIÓN DEL VECTOR DE COINTEGRACIÓN

equation eq_d.ls lnconsumo lnpib
freeze(eq_dols) eq_d.cointreg(method=dols,trend=linear,lltype=sic)
eq_d.makeresid u

'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
'---------------------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------------------
'===== Establecer directorio de trabajo
cd "C:\Users\abrah\OneDrive\Documentos"

'===== Crear workfile trimestral
wfcreate(wf=PC4_p3_1_2) q 1994q01 2021q02

'===== Importar datos desde el nuevo archivo
import "C:\Users\abrah\OneDrive\Documentos\P3data.xlsx" colhead=1 na="#N/A" @freq Q 1994Q01 @smpl @all

for %a tipocambio ipc
	
	freeze(graf_{%a}) {%a}.line

next

for %a %b tipocambio tipocambio ipc ipc

	{%a}.x12
	series ln{%b} = log({%a}_sa)
	
next

'Graficamos ambas series y analizamos tendencias comunes

for %a %b %c niveles tipocambio ipc sa tipocambio_sa ipc_sa logs lntipocambio lnipc

	group {%a} {%b} {%c}
	freeze(graf_{%a}) {%a}.line

next

freeze(graf_relacion_2) graf_niveles graf_sa graf_logs


'******* ANÁLISIS DE COINTEGRACIÓN **********

'***** PASO 1: ANÁLISIS DE RAÍZ UNITARIA

'Test de Raíz Unitaria

	for %a lntipocambio lnipc
                      
		freeze(ur_adf_{%a}) {%a}.uroot(adf, info=maic, trend)
		freeze(ur_pp_{%a}) {%a}.uroot(pp, info=maic, trend)
		freeze(ur_gls_{%a}) {%a}.uroot(dfgls, info=maic, trend)
		freeze(ur_ers_{%a}) {%a}.uroot(ers, info=maic, trend)

	next

'A fin de mostrar todos los resultados de todos los test para ambas series, estos se juntarán en una sola tabla:

	'Creamos la tabla
	
		table(10,10) tabla_uroot
		tabla_uroot(2,1)="Ho: La serie tiene raíz unitaria."
		tabla_uroot(4,1)= "Variables 1/"
		tabla_uroot(4,2)= "ADF"
		tabla_uroot(4,3)= "PP"
		tabla_uroot(4,4)= "GLS"
		tabla_uroot(4,5)= "ERS"
		tabla_uroot(5,1)= "Estadistico al 5%"
		tabla_uroot(6,1)= "tipocambio"
		tabla_uroot(7,1)= "IPC"
		tabla_uroot(9,1)= "1/ Se ha considerado el logaritmo de las series desestacionalizadas."

   'Llenamos la tabla
			
		setcell(tabla_uroot,5,2,ur_adf_lntipocambio(9,4))
		setcell(tabla_uroot,5,3,ur_pp_lntipocambio(9,4))
		setcell(tabla_uroot,5,4,ur_gls_lntipocambio(9,5))
		setcell(tabla_uroot,5,5,ur_ers_lntipocambio(11,5))

		for %a %1 lntipocambio 6 lnipc 7

			setcell(tabla_uroot,{%1},2,ur_adf_{%a}(7,4))
			setcell(tabla_uroot,{%1},3,ur_pp_{%a}(7,4))
			setcell(tabla_uroot,{%1},4,ur_gls_{%a}(7,5))
			setcell(tabla_uroot,{%1},5,ur_ers_{%a}(9,5))

		next


'******* PASO 2: ESTIMACIÓN POR MCO

'Estimamos por MCO y guardamos los residuos

equation mco.ls lntipocambio  lnipc
freeze(mco_1) mco.ls lntipocambio lnipc c @trend
mco.makeresid e

'Graficando el residuo

series resid_prom = @mean(e)
group grupo_e e resid_prom
freeze(graph_resid) grupo_e.line

'********** PASO 3: TEST DE COINTEGRACIÓN

''''''''''''''''' Trabajando con las series desestacionalizadas y en logs

'Metodología Engle y Granger

for %a none constant linear

freeze(test_{%a}_eg) logs.coint(method=eg, trend={%a},lagtype=maic)

next


table(30,30) tabla_test_coint

tabla_test_coint(2,1)="Método Engle y Granger"
tabla_test_coint(4,1)="Ho: Las series no están cointegradas"
tabla_test_coint(6,1)="Modelo sin componente determinístico"
tabla_test_coint(8,1)="Series"
tabla_test_coint(8,2)="p-value tau"
tabla_test_coint(8,3)="p-value z"
tabla_test_coint(9,1)="tipocambio"
tabla_test_coint(10,1)="IPC"
tabla_test_coint(12,1)="Modelo con intercepto"
tabla_test_coint(14,1)="Series"
tabla_test_coint(14,2)="p-value tau"
tabla_test_coint(14,3)="p-value z"
tabla_test_coint(15,1)="tipocambio"
tabla_test_coint(16,1)="IPC"
tabla_test_coint(18,1)="Modelo con intercepto y tendencia"
tabla_test_coint(20,1)="Series"
tabla_test_coint(20,2)="p-value tau"
tabla_test_coint(20,3)="p-value z"
tabla_test_coint(21,1)="tipocambio"
tabla_test_coint(22,1)="IPC"


for %a %1 %2 %3 none 9 11 11 none 10 12 12 constant 15 12 12 constant 16 13 13 linear 21 12 12 linear 22 13 13

'Engle y Granger
	setcell(tabla_test_coint,{%1},2,test_{%a}_eg({%2},3),3)
	setcell(tabla_test_coint,{%1},3,test_{%a}_eg({%2},5),3)

next

'*********** PASO 4: ESTIMACIÓN DEL VECTOR DE COINTEGRACIÓN

equation eq_d.ls lntipocambio lnipc
freeze(eq_dols) eq_d.cointreg(method=dols,trend=linear,lltype=sic)
eq_d.makeresid u


'===== Establecer directorio de trabajo
cd "C:\Users\abrah\OneDrive\Documentos"



'===== Crear workfile trimestral
wfcreate(wf=PC4_p3_1_3) q 1994q01 2021q02


'===== Importar datos desde el nuevo archivo
import "C:\Users\abrah\OneDrive\Documentos\P3data.xlsx" colhead=1 na="#N/A" @freq Q 1994Q01 @smpl @all


'a)
'for %a money ipc ipc
	
'	freeze(graf_{%a}) {%a}.line

'next

'Dado que las series son de frecuencia trimestral, es probable que muestren estacionalidad. Se observa un comportamiento estacional en los gráficos. En tal sentido, se desestacionalizará cada serie y se sacará su logaritmo.

'Desestacionalizamos las series usando el Census X12 y la expresamos en logs:

for %a %b money money ipc ipc

	{%a}.x12
	series ln{%b} = log({%a}_sa)
	
next

'Graficamos ambas series y analizamos tendencias comunes

for %a %b %c niveles1 money ipc sa1 money_sa ipc_sa logs1 lnmoney lnipc

	group {%a} {%b} {%c}
	freeze(graf_{%a}) {%a}.line

next

freeze(graf_relacion_1) graf_niveles1 graf_sa1 graf_logs1

'******* ANÁLISIS DE COINTEGRACIÓN **********

'***** PASO 1: ANÁLISIS DE RAÍZ UNITARIA

'Tal y como se puede apreciar, ambas series muestran intercepto y tendencia. En tal sentido, se testeará raíz unitaria incluyendo ambos componentes. Asimismo, dado que nos encontramos en un escenario de posible no estacionariedad, el criterio de selección de rezagos para los test será el "Modified Akaike" (MAIC). Con el uso de este criterio preferimos sacrificar potencia a cambio de corregir definitivamente la autocorrelación.

	'Test de Raíz Unitaria

	for %a lnmoney lnipc
                      
		freeze(ur_adf_{%a}) {%a}.uroot(adf, info=maic, trend)
		freeze(ur_pp_{%a}) {%a}.uroot(pp, info=maic, trend)
		freeze(ur_gls_{%a}) {%a}.uroot(dfgls, info=maic, trend)
		freeze(ur_ers_{%a}) {%a}.uroot(ers, info=maic, trend)

	next
'A fin de mostrar todos los resultados de todos los test para ambas series, estos se juntarán en una sola tabla:

	'Creamos la tabla
	
		table(10,10) tabla_uroot
		tabla_uroot(2,1)="Ho: La serie tiene raíz unitaria."
		tabla_uroot(4,1)= "Variables 1/"
		tabla_uroot(4,2)= "ADF"
		tabla_uroot(4,3)= "PP"
		tabla_uroot(4,4)= "GLS"
		tabla_uroot(4,5)= "ERS"
		tabla_uroot(5,1)= "Estadistico al 5%"
		tabla_uroot(6,1)= "money"
		tabla_uroot(7,1)= "IPC"
		tabla_uroot(9,1)= "1/ Se ha considerado el logaritmo de las series desestacionalizadas."

   'Llenamos la tabla
			
		setcell(tabla_uroot,5,2,ur_adf_lnmoney(9,4))
		setcell(tabla_uroot,5,3,ur_pp_lnmoney(9,4))
		setcell(tabla_uroot,5,4,ur_gls_lnmoney(9,5))
		setcell(tabla_uroot,5,5,ur_ers_lnmoney(11,5))

		for %a %1 lnmoney 6 lnipc 7

			setcell(tabla_uroot,{%1},2,ur_adf_{%a}(7,4))
			setcell(tabla_uroot,{%1},3,ur_pp_{%a}(7,4))
			setcell(tabla_uroot,{%1},4,ur_gls_{%a}(7,5))
			setcell(tabla_uroot,{%1},5,ur_ers_{%a}(9,5))

		next

'******* PASO 2: ESTIMACIÓN POR MCO

'Estimamos por MCO y guardamos los residuos

equation mco.ls lnmoney lnipc
freeze(mco_1) mco.ls lnmoney lnipc c @trend
mco.makeresid e

'Graficando el residuo

series resid_prom = @mean(e)
group grupo_e e resid_prom
freeze(graph_resid) grupo_e.line

for %a none constant linear

freeze(test_{%a}_eg) logs1.coint(method=eg, trend={%a},lagtype=maic)

next


table(30,30) tabla_test_coint

tabla_test_coint(2,1)="Método Engle y Granger"
tabla_test_coint(4,1)="Ho: Las series no están cointegradas"
tabla_test_coint(6,1)="Modelo sin componente determinístico"
tabla_test_coint(8,1)="Series"
tabla_test_coint(8,2)="p-value tau"
tabla_test_coint(8,3)="p-value z"
tabla_test_coint(9,1)="money"
tabla_test_coint(10,1)="IPC"
tabla_test_coint(12,1)="Modelo con intercepto"
tabla_test_coint(14,1)="Series"
tabla_test_coint(14,2)="p-value tau"
tabla_test_coint(14,3)="p-value z"
tabla_test_coint(15,1)="money"
tabla_test_coint(16,1)="IPC"
tabla_test_coint(18,1)="Modelo con intercepto y tendencia"
tabla_test_coint(20,1)="Series"
tabla_test_coint(20,2)="p-value tau"
tabla_test_coint(20,3)="p-value z"
tabla_test_coint(21,1)="money"
tabla_test_coint(22,1)="IPC"


for %a %1 %2 %3 none 9 11 11 none 10 12 12 constant 15 12 12 constant 16 13 13 linear 21 12 12 linear 22 13 13

'Engle y Granger
	setcell(tabla_test_coint,{%1},2,test_{%a}_eg({%2},3),3)
	setcell(tabla_test_coint,{%1},3,test_{%a}_eg({%2},5),3)

next




'       PREGUNTA 3.2
'       METODOLOGIA DE JOHANSEN

close @all
'===== Establecer directorio de trabajo
cd "C:\Users\abrah\OneDrive\Documentos"

'===== Crear workfile trimestral
wfcreate(wf=PC4_p3_1_2) q 1994q01 2021q02

'===== Importar datos desde el nuevo archivo
import "C:\Users\abrah\OneDrive\Documentos\P3data.xlsx" colhead=1 na="#N/A" @freq Q 1994Q01 @smpl @all

rename tasapasiva t_pasiva
rename tasaactiva t_activa


'lrm: log de dinero real ; lry: log de pbi real; lp: log de precios 

series lnmoney = log(money) 
series lnpib = log(pib)
series lnp = log(ipc)

group grupo5 lnmoney lnpib lnp t_pasiva t_activa

freeze(graf_variables) grupo5.line(m)

var var1.ls 1 2 lnmoney lnpib lnp t_pasiva @ c @seas(2) @seas(3) @seas(4)

var var1B.ls 1 2 lnmoney lnpib lnp t_pasiva t_activa @ c @seas(2) @seas(3) @seas(4)

freeze(tabla_auto_LM) var1B.arlm(8)

freeze(tabla_auto_LM1) var1.arlm(8)

freeze(tabla_norm) var1.jbera(facto=chol)

freeze(raices) var1.arroots

freeze(tabla_coint) var1.coint(cvtype=ol, b, 2)

var vec.ec(b, 1) 1 2 lnmoney lnpib lnp t_pasiva @ c @seas(2) @seas(3) @seas(4)


'imponiendo restricciones
'Hipótesis a.
vec.cleartext(coint)
vec.append(coint) b(1,1)=1, b(1,1)=-b(1,2)
'b(1: primer vector de cointegracion, 1: primera variable)
vec.ec(restrict) 1 2 lnmoney lnpib lnp t_pasiva @ c @seas(2) @seas(3) @seas(4)

'Hipótesis b.
vec.cleartext(coint)
vec.append(coint) b(1,1)=1, b(1,1)=-b(1,2), b(1,3)=-b(1,4)
vec.ec(restrict) 1 2 lnmoney lnpib lnp t_pasiva @ c @seas(2) @seas(3) @seas(4)


