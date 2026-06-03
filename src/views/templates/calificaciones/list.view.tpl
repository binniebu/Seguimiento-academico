<h1>Consultar Calificaciones</h1>
<hr>

<section class="grid">
    <form action="index.php" method="get" class="row py-3">
        <input type="hidden" name="page" value="Calificaciones">
        <div class="col-12 col-m-8">
            <label for="partialName">Buscar por Estudiante o Materia</label>
            <input type="text" name="partialName" id="partialName" value="{{partialName}}" placeholder="Nombre...">
        </div>
        <div class="col-12 col-m-4 align-end">
            <button type="submit" class="btn primary">Buscar</button>
        </div>
    </form>
</section>

<section class="WWTable">
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Estudiante</th>
                <th>Materia</th>
                <th>Periodo</th>
                <th>Nota</th>
                <th>Observación</th>
                <th><a href="index.php?page=Calificacion&mode=INS" class="btn primary center">+ Registrar Nota</a></th>
            </tr>
        </thead>
        <tbody>
            {{foreach calificaciones}}
            <tr>
                <td>{{id_calificacion}}</td>
                <td>{{nombre_estudiante}}</td>
                <td>{{nombre_materia}}</td>
                <td>{{periodo}}</td>
                <td><strong>{{nota}}%</strong></td>
                <td>{{observacion}}</td>
                <td class="center">
                    <a href="index.php?page=Calificacion&mode=DSP&id_calificacion={{id_calificacion}}" class="btn secondary sm">Ver</a>
                    <a href="index.php?page=Calificacion&mode=UPD&id_calificacion={{id_calificacion}}" class="btn primary sm">Editar</a>
                    <a href="index.php?page=Calificacion&mode=DEL&id_calificacion={{id_calificacion}}" class="btn danger sm">Eliminar</a>
                </td>
            </tr>
            {{endfor calificaciones}}
        </tbody>
    </table>
    {{pagination}}
</section>