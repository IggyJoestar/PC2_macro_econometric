% ------------------------------------------------------------------
%%       PREGUNTA 04: Raíz Unitaria - Valores Críticos 
% ------------------------------------------------------------------

clear all
clc;

% colocamos nuestra semilla
rng(1234);


%% Parámetros de los procesos GDP:
% ==========================================================
% 1) y_t = α*y_{t-1} + ε_t
% 2) y_t = β + α*y_{t-1} + ε_t
% ==========================================================

N = 50000; % num. de réplicas Monte Carlo
T = 1001;  % longitud de cada serie temporal 
beta = 0.1; % intercepto (componente determinístico)
y0 = 0;     % condición inicial 
alpha = 1;  % coeficiente autoregresivo

% H0: α = 1 (proceso no estacionario, raíz unitaria)

%% generamos las innovaciones ~ N(0,1)
e1 = randn(T,N); % proceso 1
e2 = randn(T,N); % proceso 2

%% matriz cascarón para las series
y1_ar1 = zeros(T,N); 
y2_ar1 = zeros(T,N); 

%% Simulación de los procesos AR(1)
% ==========================================================
for t = 2:T
    for i = 1:N
        % Proceso sin intercepto (1)
        y1_ar1(t,i) = alpha * y1_ar1(t-1,i) + e1(t,i);
        
        % Proceso con intercepto (2)
        y2_ar1(t,i) = beta + alpha * y2_ar1(t-1,i) + e2(t,i); 
    end
end

%% Detrending (solo necesario para (1))
% ==========================================================
% removemos la media estimada:
% ψ_2 = (1/T) * Σ y2(t) [estimación de la media]
% y2det(t) = y2(t) - ψ_2
% ==========================================================
psi2 = mean(y2_ar1(2:end,:)); 

% series cascarón de detrended
y1det = zeros(T-1,N); % 1 -> solo eliminamos y0
y2det = zeros(T-1,N); % 2 -> restamos la media

for t = 2:T
    for i = 1:N
        y1det(t-1,i) = y1_ar1(t,i); 
        y2det(t-1,i) = y2_ar1(t,i) - psi2(i); % detrending
    end
end

clear y2_ar1 y1_ar1 

%% primer rezago (y1_1det = y1det(t-1) 
y1_1det = y1det(1:(end-1),:);
y2_1det = y2det(1:(end-1),:);

%% primera diferencia (Δy_t = y_t - y_{t-1})
deltay1det = diff(y1det);
deltay2det = diff(y2det);

%% Estimación del coeficiente α 
% ==========================================================
% regresión ADF: Δy_t = α*y_{t-1} + error
% MCO:
% α̂ = Σ(y_{t-1}*Δy_t) / Σ(y_{t-1}^2)
% ==========================================================

% numerador: Σ(y_{t-1}*Δy_t)
Num1 = sum(y1_1det .* deltay1det); 
Num2 = sum(y2_1det .* deltay2det); 

% denominador: Σ(y_{t-1}^2)
Den1 = sum(y1_1det.^2); 
Den2 = sum(y2_1det.^2); 

% Estimación de α
alpha1 = Num1 ./ Den1; 
alpha2 = Num2 ./ Den2; 

%% Residuales de la regresión ADF
% e_t = Δy_t - α̂*y_{t-1}
edet1 = deltay1det - y1_1det .* alpha1;
edet2 = deltay2det - y2_1det .* alpha2;

%% Error estándar del estimador α̂
% ==========================================================
% σ̂² = (1/(T-k)) * Σ e_t^2 [varianza residual]
% Var(α̂) = σ̂² / Σ(y_{t-1}^2)
% SE(α̂) = sqrt(Var(α̂))
% ==========================================================
% suma de cuadrados residuales 
e2det1 = sum(edet1.^2); 
e2det2 = sum(edet2.^2); 

% error estándar
se1 = sqrt( (e2det1./(T-1)) ./ Den1 ); % 1 grado de libertad
se2 = sqrt( (e2det2./(T-2)) ./ Den2 ); % 2 grado de libertad

%%                   Estadístico ADF
% ==========================================================
% ADF = α̂ / SE(α̂) , bajo H0 (α=1)
% ==========================================================
ADF1 = alpha1 ./ se1;
ADF2 = alpha2 ./ se2; 

%% Valores críticos empíricos
% percentiles 1%, 5% y 10% 
ADF1proc1 = prctile(ADF1, [1 5 10], 2); 
ADF2proc1 = prctile(ADF2, [1 5 10], 2); 

disp('Valores críticos - gdp 1 (sin intercepto):');
disp(ADF1proc1);
disp('Valores críticos - gdp 2 (con intercepto):');
disp(ADF2proc1);


%%  2. Estadístico MSB - Stock (1999)
% ==========================================================
% MSB = (T^{-2}Σy_{t-1}^2)^{1/2} / (σ̂^2)^{1/2}
% donde σ̂^2 es el estimador de la varianza de los errores
% ==========================================================

% varianza residual (T-k grados libertad)
s2_1 = e2det1 ./ (T-1); 
s2_2 = e2det2 ./ (T-2); 

MSB1 = sqrt(Den1) ./ (T * sqrt(s2_1)); 
MSB2 = sqrt(Den2) ./ (T * sqrt(s2_2)); 

% valores críticos
MSB1_perc = prctile(MSB1, [1 5 10]);
MSB2_perc = prctile(MSB2, [1 5 10]);

disp('Valores críticos MSB (Stock 1999):');
disp('Sin intercepto:'); disp(MSB1_perc);
disp('Con intercepto:'); disp(MSB2_perc);

%% 3. Estadístico DF-GLS de Elliott
%%  Rothenberg y Stock (1996)
% ==========================================================
% transformación GLS para mejorar potencia:
% y_t^d = y_t - ρy_{t-1}, donde ρ = 1 + c̄/T
% Para modelo con intercepto: c̄ = -7
% ==========================================================

% parámetros GLS
c_bar = -7; % para modelo con intercepto
rho = 1 + c_bar/T;

% matriz cascarón de series GLS
y2_gls = zeros(size(y2det));

% transformación GLS 
for t = 2:T-1
    y2_gls(t,:) = y2det(t,:) - rho * y2det(t-1,:);
end

y_lag_gls = y2det(1:end-1,:); % y_{t-1} original
y2_gls = y2_gls(2:end,:); % eliminamos primera observación


% estimación de αGLS
NumGLS = sum(y_lag_gls .* y2_gls);
DenGLS = sum(y_lag_gls.^2);
alphaGLS = NumGLS ./ DenGLS;

% residuales GLS
residGLS = y2_gls - alphaGLS .* y_lag_gls;
s2GLS = sum(residGLS.^2) ./ (T-3); % grados libertad (intercepto + GLS)

% estadístico DF-GLS
seGLS = sqrt(s2GLS ./ DenGLS);
DFGLS = alphaGLS ./ seGLS;
DFGLS_perc = prctile(DFGLS, [1 5 10]);

disp('Valores críticos DF-GLS (ERS 1996) - Proceso 2:');
disp(DFGLS_perc);

%% 4. Estadístico MSB-GLS - Ng y Perron (2001)
% ==========================================================
% MSB-GLS = (T^{-2}Σ(y_{t-1}^d)^2)^{1/2} / (σ̂^2)^{1/2}
% donde y_{t-1}^d es la serie transformada GLS
% ==========================================================

% usamos la misma transformación GLS anterior

MSBGLS = sqrt(sum(y_lag_gls.^2, 1)) ./ (T * sqrt(s2GLS));
MSBGLS_perc = prctile(MSBGLS, [1 5 10]);

disp('Valores críticos MSB-GLS');
disp(MSBGLS_perc);
