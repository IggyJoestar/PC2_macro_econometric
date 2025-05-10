
T = 200;             % Tamaño de la muestra
sigma2 = 0.1;        % Varianza del ruido
rng(1);              % Semilla para reproducibilidad
phi = 1;
y = zeros(T,1);
nu = sqrt(sigma2) * randn(T,1);
for t = 2:T
    y(t) = phi*y(t-1) + nu(t);
end
y1 = y;  % Guardamos para graficar más adelante
phi = 0.99;
y = zeros(T,1);
nu = sqrt(sigma2) * randn(T,1);
for t = 2:T
    y(t) = phi*y(t-1) + nu(t);
end
y2 = y;
phi = 0.95;
y = zeros(T,1);
nu = sqrt(sigma2) * randn(T,1);
for t = 2:T
    y(t) = phi*y(t-1) + nu(t);
end
y3 = y;
figure;
subplot(3,1,1);
plot(y1);
title('Serie con \phi = 1 (Raíz Unitaria)');

subplot(3,1,2);
plot(y2);
title('Serie con \phi = 0.99');

subplot(3,1,3);
plot(y3);
title('Serie con \phi = 0.95');
figure;
subplot(3,2,1);
autocorr(y1);
title('ACF \phi = 1');

subplot(3,2,2);
parcorr(y1);
title('PACF \phi = 1');

subplot(3,2,3);
autocorr(y2);
title('ACF \phi = 0.99');

subplot(3,2,4);
parcorr(y2);
title('PACF \phi = 0.99');

subplot(3,2,5);
autocorr(y3);
title('ACF \phi = 0.95');

subplot(3,2,6);
parcorr(y3);
title('PACF \phi = 0.95');
T = 200;             % Tamaño de la muestra
sigma2 = 0.1;        % Varianza del ruido
rng(1);              % Semilla para reproducibilidad
phi = 1;
y = zeros(T,1);
nu = sqrt(sigma2) * randn(T,1);
for t = 2:T
    y(t) = phi*y(t-1) + nu(t);
end
y1 = y;  % Guardamos para graficar más adelante
phi = 0.99;
y = zeros(T,1);
nu = sqrt(sigma2) * randn(T,1);
for t = 2:T
    y(t) = phi*y(t-1) + nu(t);
end
y2 = y;
phi = 0.95;
y = zeros(T,1);
nu = sqrt(sigma2) * randn(T,1);
for t = 2:T
    y(t) = phi*y(t-1) + nu(t);
end
y3 = y;
figure;
subplot(3,1,1);
plot(y1);
title('Serie con \phi = 1 (Raíz Unitaria)');

subplot(3,1,2);
plot(y2);
title('Serie con \phi = 0.99');

subplot(3,1,3);
plot(y3);
title('Serie con \phi = 0.95');
figure;
subplot(3,2,1);
autocorr(y1);
title('ACF \phi = 1');

subplot(3,2,2);
parcorr(y1);
title('PACF \phi = 1');

subplot(3,2,3);
autocorr(y2);
title('ACF \phi = 0.99');

subplot(3,2,4);
parcorr(y2);
title('PACF \phi = 0.99');

subplot(3,2,5);
autocorr(y3);
title('ACF \phi = 0.95');

subplot(3,2,6);
parcorr(y3);
title('PACF \phi = 0.95');
% En el proceso con raíz unitaria, donde phi es igual a 1, podemos observar
% en la ACF que decae lentamente, lo cual es característica de un proceso
% raíz unitaria o paseo aleatorio. La autocorrelación en todos los rezagos
% es alta. En la PACF, se observa un fuerte pico en el primer rezago, pero
% los demás rezagos caen dentro del intervalo de confianza. En el proceso
% AR cercano a raíz unitaria con phi igual a 0.99, la ACF decae muy
% lentamente pero vemos que si tiende a disminuir con el tiempo. En la
% PACF, se observa un pico fuerte al inicio pero luego decae. Es similar al
% anterior caso, pero con menor persistencia. Por último, en el proceso AR
% con phi igual a 0.95, en la ACF se observa que decae mas rápido que el proceso con
% phi igual a 0.99, se observa un decaimento exponencial. En la PACF, se
% observa un pico fuerte en el primer rezago, pero luego es menor en los
% siguientes. Es característico de un proceso AR estacionario.