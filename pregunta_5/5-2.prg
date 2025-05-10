'necesario establecer cd
wfopen ""data.xlsx"" range=ANUAL

' === TABLA 4: Sample autocorrelations of deviations from time trend ===

%series = "RGNP GNP PCRGNP IP EMP UN PRGNP CPI WG RWG M VEL BND SP500"
!n = 14

table(15,7) tabla4
tabla4(1,1) = "Serie"
for !col = 2 to 7
	tabla4(1,!col) = "r" + @str(!col-1)
next

' Matriz para guardar autocorrelaciones de residuos
matrix(!n,6) res_cor
!fila = 1

' Estimamos regresión log(y_t) ~ c + trend, guardamos residuos y calculamos r1 a r6
for %i {%series}
	
	if %i = "BND" then
		series {%i} = {%i}
	else
		series {%i} = log({%i})
	endif

	equation eq_{%i}.ls {%i} c @trend
	eq_{%i}.makeresids res_{%i}

	for !k = 1 to 6
		res_cor(!fila, !k) = @cor(res_{%i}, res_{%i}(-!k))
	next

	!fila = !fila + 1
next

' Llenamos tabla con los resultados
!fila = 2
!row = 1
for %i {%series}
	setcell(tabla4, !fila, 1, %i)
	for !k = 1 to 6
		setcell(tabla4, !fila, !k + 1, @str(res_cor(!row, !k), "f.3"))
	next
	!fila = !fila + 1
	!row = !row + 1
next

show tabla4

