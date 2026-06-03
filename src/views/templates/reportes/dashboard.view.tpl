<h1>Módulo de Analítica y Reportes</h1>
<p class="subtitle">Indicadores de rendimiento académico global</p>
<hr>

<section class="row gap-2 mb-4">
    <div class="col-12 col-m-4 card p-3 center" style="border-left: 5px solid #2ecc71;">
        <h3>Estudiantes Totales</h3>
        <p class="h1 font-weight-bold" style="font-size: 2.5rem; margin: 10px 0;">{{total_estudiantes}}</p>
        <small>Registrados en la plataforma</small>
    </div>
    <div class="col-12 col-m-4 card p-3 center" style="border-left: 5px solid #3498db;">
        <h3>Estudiantes Activos</h3>
        <p class="h1 font-weight-bold" style="font-size: 2.5rem; margin: 10px 0;">{{estudiantes_activos}}</p>
        <small>Con clases inscritas en este período</small>
    </div>
    <div class="col-12 col-m-4 card p-3 center" style="border-left: 5px solid #9b59b6;">
        <h3>Cupos Ocupados</h3>
        <p class="h1 font-weight-bold" style="font-size: 2.5rem; margin: 10px 0;">{{total_cupos}}</p>
        <small>Total de asignaciones en materias</small>
    </div>
</section>

<h2 class="mt-4"><span class="ion-stats-bars"></span> Rendimiento por Materia y Promedios</h2>
<section class="WWTable card mb-4">
    <table>
        <thead>
            <tr>
                <th>Código</th>
                <th>Asignatura</th>
                <th class="center">Notas Evaluadas</th>
                <th class="center">Nota Promedio</th>
                <th class="center">Nota más Alta</th>
                <th class="center">Nota más Baja</th>
            </tr>
        </thead>
        <tbody>
            {{foreach reporte_materias}}
            <tr>
                <td>{{codigo}}</td>
                <td><strong>{{materia}}</strong></td>
                <td class="center">{{evaluaciones_registradas}}</td>
                <td class="center" style="color: #27ae60; font-weight: bold;">{{if promedio_nota}}{{promedio_nota}}%{{ifnot promedio_nota}}N/A{{endif promedio_nota}}</td>
                <td class="center">{{if nota_mas_alta}}{{nota_mas_alta}}%{{ifnot nota_mas_alta}}-{{endif nota_mas_alta}}</td>
                <td class="center">{{if nota_mas_baja}}{{nota_mas_baja}}%{{ifnot nota_mas_baja}}-{{endif nota_mas_baja}}</td>
            </tr>
            {{endfor reporte_materias}}
        </tbody>
    </table>
</section>

<div class="row gap-3">
    <div class="col-12 col-l-6">
        <h2><span class="ion-person"></span> Reporte Detallado por Estudiante</h2>
        <section class="WWTable card p-2" style="max-height: 400px; overflow-y: auto;">
            <table>
                <thead>
                    <tr>
                        <th>Estudiante</th>
                        <th>Materia</th>
                        <th>Nota</th>
                    </tr>
                </thead>
                <tbody>
                    {{foreach reporte_estudiantes}}
                    <tr>
                        <td>{{estudiante}} <br><small class="text-muted">{{cuenta}}</small></td>
                        <td>{{materia}}</td>
                        <td><span class="badge primary">{{nota}}%</span></td>
                    </tr>
                    {{endfor reporte_estudiantes}}
                </tbody>
            </table>
        </section>
    </div>

    <div class="col-12 col-l-6">
        <h2><span class="ion-briefcase"></span> Reporte de Carga por Maestro</h2>
        <section class="WWTable card p-2" style="max-height: 400px; overflow-y: auto;">
            <table>
                <thead>
                    <tr>
                        <th>Catedrático</th>
                        <th>Clase Impartida</th>
                        <th class="center">Alumnos</th>
                    </tr>
                </thead>
                <tbody>
                    {{foreach reporte_maestros}}
                    <tr>
                        <td>{{maestro}} <br><small class="text-muted">{{codigo_maestro}}</small></td>
                        <td>{{materia}}</td>
                        <td class="center"><span class="badge secondary">{{total_alumnos}}</span></td>
                    </tr>
                    {{endfor reporte_maestros}}
                </tbody>
            </table>
        </section>
    </div>
</div>