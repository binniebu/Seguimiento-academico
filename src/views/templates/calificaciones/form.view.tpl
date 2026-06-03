<h1>{{FormTitle}}</h1>
<hr>

<section class="row py-3">
    {{with calificacion}}
    <form action="index.php?page=Calificacion&mode={{mode}}&id_calificacion={{id_calificacion}}" method="post" class="col-12 col-m-8 offset-m-2 card p-4">
        <input type="hidden" name="id_calificacion" value="{{id_calificacion}}">

        <div class="row mb-3">
            <label class="col-12 col-m-4 px-2 py-1" for="id_matricula">Estudiante / Clase</label>
            <div class="col-12 col-m-8">
                <select class="width-full" name="id_matricula" id="id_matricula" {{if ~readonly}}disabled{{endif ~readonly}}>
                    <option value="0">-- Seleccione una Matrícula --</option>
                    {{foreach ~matriculas}}
                        <option value="{{id_matricula}}" {{selected}}>{{nombre_estudiante}} - {{nombre_materia}} ({{periodo}})</option>
                    {{endfor ~matriculas}}
                </select>
                {{if id_matricula_error}}
                    <div class="error">{{id_matricula_error}}</div>
                {{endif id_matricula_error}}
            </div>
        </div>

        <div class="row mb-3">
            <label class="col-12 col-m-4 px-2 py-1" for="nota">Nota Obtenida</label>
            <div class="col-12 col-m-8">
                <input class="width-full" type="number" step="0.01" id="nota" name="nota" value="{{nota}}" min="0" max="100" placeholder="0.00" {{readonly}}>
                {{if nota_error}}
                    <div class="error">{{nota_error}}</div>
                {{endif nota_error}}
            </div>
        </div>

        <div class="row mb-4">
            <label class="col-12 col-m-4 px-2 py-1" for="observacion">Observación</label>
            <div class="col-12 col-m-8">
                <input class="width-full" type="text" id="observacion" name="observacion" value="{{observacion}}" placeholder="Ej. Excelente rendimiento o acumulados completos" {{readonly}}>
            </div>
        </div>

        <div class="row flex end gap-2">
            {{if ~showCommitBtn}}
                <button type="submit" class="btn primary">Guardar</button>
            {{endif ~showCommitBtn}}
            <a href="index.php?page=Calificaciones" class="btn secondary">Cancelar</a>
        </div>
    </form>
    {{endwith calificacion}}
</section>