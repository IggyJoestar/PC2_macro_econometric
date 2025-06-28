'=== Configuración inicial ===
cd "C:\Users\LENOVO\Downloads\Copia de Series de pbi tc r ipc japon.xlsx"
smpl 1994Q1 2022Q4

'=== Importar archivo completo ===
import "Copia de Series de pbi tc r ipc japon.xlsx" range="Sheet1" colhead=1

'=== Renombrar las variables ===
rename JPNRGDPEXP pbi_real
rename LRUN64TTJPQ156S tasa_desempleo

'=== Transformaciones logarítmicas ===
series log_pbi = log(pbi_real)
series log_desemp = log(tasa_desempleo)

'=== Pruebas de raíz unitaria (ADF) ===
freeze(adf_pbi) log_pbi.uroot(adf, trend, lagmethod=tstat)
freeze(adf_desemp) log_desemp.uroot(adf, trend, lagmethod=tstat)

'=== Series en primeras diferencias (estacionarias) ===
series dlog_pbi = d(log_pbi)
series dlog_desemp = d(log_desemp)

'=== Guardar/exportar como CSV para MATLAB ===
wfsave "japan_macro_data.wf1"
pagesave(t=csv) japan_data.csv
%% === Cargar datos ===
data = readtable("japan_data.csv");
Y = [data.dlog_pbi, data.dlog_desemp];  % Orden: [PBI, Desempleo]

%% === Estimar VAR reducido ===
p = 4;  % Puedes ajustar esto según AIC/BIC
Mdl = varm(2, p);
EstMdl = estimate(Mdl, Y);

%% === Impulse Response con restricciones contemporáneas (Cholesky) ===
[IRF_chol, ~] = irf(EstMdl, 'NumObs', 20, 'Method', 'orthogonalized');

% Gráfico de IRFs
figure;
subplot(2,1,1); plot(IRF_chol(:,1,1)); title("IRF PIB ante Shock 1");
subplot(2,1,2); plot(IRF_chol(:,2,1)); title("IRF Desempleo ante Shock 1");

%% === Identificación con restricciones de signo ===
% Signos esperados: fila = shock, columna = variable
% Shock 1 (Demanda): PIB ↑, Desemp ↓
% Shock 2 (Oferta negativa): PIB ↓, Desemp ↑
signs = [ +1, -1;
          -1, +1 ];
