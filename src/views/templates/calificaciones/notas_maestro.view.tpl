<?php
require_once __DIR__ . "/../../../dao/CalificacionDao.php";
require_once __DIR__ . "/../../../dao/PeriodoDao.php";
require_once __DIR__ . "/../../../dao/MaestroDao.php";
require_once __DIR__ . "/../../../dao/Dao.php";
require_once __DIR__ . "/../../../dao/Table.php";
use Dao\CalificacionDao;
use Dao\PeriodoDao;
use Dao\MaestroDao;
use Dao\Table;
if (session_status() === PHP_SESSION_NONE) { session_start(); }
$idUsuario = $_SESSION["id_usuario"] ?? null;
$maestroRow = MaestroDao::obtenerMaestroPorIdUsuario($idUsuario);
if (!$maestroRow) {
    echo "<script>alert('Sin perfil de maestro.');window.location='index.php?page=home';</script>";
    exit();
}
$idMaestro = intval($maestroRow["id_maestro"]);
$periodo   = PeriodoDao::obtenerPeriodoActivo();
$secciones = $periodo
    ? CalificacionDao::obtenerSeccionesMaestro($idMaestro, intval($periodo["id_periodo"]))
    : [];
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calificaciones — Mis Secciones</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
    <style>
        .seccion-card { transition: box-shadow .2s; }
        .seccion-card:hover { box-shadow: 0 4px 20px rgba(0,0,0,.10) !important; }
        .nota-input {
            width: 82px; text-align: center; border-radius: 8px;
            border: 1.5px solid #dee2e6; padding: 5px 4px; font-size: .9rem;
            transition: border-color .2s;
        }
        .nota-input:focus { border-color: #0d6efd; outline: none; box-shadow: 0 0 0 3px rgba(13,110,253,.15); }
        .nota-input.is-invalid { border-color: #dc3545 !important; background: #fff5f5; }
        .promedio-cell { font-size: 1rem; font-weight: 700; min-width: 70px; text-align: center; }
        .badge-prog { font-size: .75rem; }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>
        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card">
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn" type="button">
                            <i class="bi bi-list"></i>
                        </button>
                        <div>
                            <h1 class="h2 page-title mb-1"><i class="bi bi-journal-check me-2"></i>Calificaciones</h1>
                            <div class="text-muted small"><?php echo $periodo ? htmlspecialchars($periodo["nombre_periodo"]) : "Sin periodo activo"; ?></div>
                        </div>
                    </div>
                    <a href="index.php?page=reporte_pdf&tipo=notas_docente" target="_blank" class="btn btn-outline-danger">
                        <i class="bi bi-file-earmark-pdf me-1"></i>Reporte docente PDF
                    </a>
                </div>

                <?php if (!$periodo): ?>
                    <div class="alert alert-warning"><i class="bi bi-exclamation-triangle me-2"></i>No hay ningun periodo academico activo.</div>
                <?php elseif (empty($secciones)): ?>
                    <div class="text-center py-5">
                        <i class="bi bi-calendar-x text-muted fs-1 d-block mb-3"></i>
                        <h5 class="text-secondary">Sin secciones asignadas</h5>
                        <p class="text-muted mb-0">No tiene secciones asignadas en el periodo activo.</p>
                    </div>
                <?php else: ?>
                    <div class="mb-4 d-flex gap-3 flex-wrap">
                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2 fs-6">
                            <i class="bi bi-collection me-1"></i><?php echo count($secciones); ?> seccion<?php echo count($secciones) !== 1 ? 'es' : ''; ?>
                        </span>
                        <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle px-3 py-2 fs-6">
                            <i class="bi bi-people me-1"></i><?php echo array_sum(array_column($secciones, "total_inscritos")); ?> estudiantes en total
                        </span>
                    </div>
                    <div class="row g-4">
                        <?php foreach ($secciones as $s):
                            $ti = intval($s["total_inscritos"]);
                            $tn = intval($s["total_con_nota"]);
                            $pg = $ti > 0 ? round(($tn / $ti) * 100) : 0;
                            $cId = "sec_" . $s["id_seccion"];
                        ?>
                        <div class="col-12">
                            <div class="card border-0 shadow-sm rounded-3 seccion-card">
                                <div class="card-header bg-white py-3 px-4 border-0 border-bottom">
                                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="bg-primary text-white rounded-3 d-flex align-items-center justify-content-center" style="width:48px;height:48px;font-size:1.3rem;">
                                                <i class="bi bi-book"></i>
                                            </div>
                                            <div>
                                                <div class="fw-bold text-dark mb-0" style="font-size:1.05rem;"><?php echo htmlspecialchars($s["nombre_materia"]); ?></div>
                                                <div class="text-muted small">
                                                    <?php echo htmlspecialchars($s["codigo_materia"]); ?> &bull;
                                                    Secc. <strong><?php echo htmlspecialchars($s["codigo_seccion"]); ?></strong> &bull;
                                                    Aula <strong><?php echo htmlspecialchars($s["aula"]); ?></strong> &bull;
                                                    <?php echo htmlspecialchars(str_replace(",","-",$s["dias"]) . " " . substr($s["hora_inicio"],0,5) . " - " . substr($s["hora_fin"],0,5)); ?>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="d-flex align-items-center gap-3 flex-wrap">
                                            <a class="btn btn-sm btn-outline-danger"
                                               href="index.php?page=reporte_pdf&tipo=notas_clase&id_seccion=<?php echo urlencode($s['id_seccion']); ?>"
                                               target="_blank">
                                                <i class="bi bi-file-earmark-pdf me-1"></i>PDF clase
                                            </a>
                                            <div style="min-width:160px;">
                                                <div class="d-flex justify-content-between mb-1">
                                                    <span class="badge-prog text-muted">Notas registradas</span>
                                                    <span class="badge-prog fw-semibold"><?php echo $tn; ?>/<?php echo $ti; ?></span>
                                                </div>
                                                <div class="progress" style="height:6px;">
                                                    <div class="progress-bar <?php echo $pg===100 ? 'bg-success':'bg-primary'; ?>" style="width:<?php echo $pg; ?>%"></div>
                                                </div>
                                            </div>
                                            <span class="badge <?php echo $s["estado"]==="Activa"?"bg-success":"bg-warning text-dark"; ?> px-2 py-1">
                                                <?php echo htmlspecialchars($s["estado"]); ?>
                                            </span>
                                            <button class="btn btn-sm btn-outline-primary"
                                                    type="button"
                                                    data-bs-toggle="collapse"
                                                    data-bs-target="#<?php echo $cId; ?>"
                                                    data-id-seccion="<?php echo $s['id_seccion']; ?>"
                                                    onclick="cargarAlumnos(this)">
                                                <i class="bi bi-people me-1"></i>Ver alumnos
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <div class="collapse" id="<?php echo $cId; ?>">
                                    <div class="card-body p-0">
                                        <div id="loader_<?php echo $s['id_seccion']; ?>" class="text-center py-4 text-muted">
                                            <div class="spinner-border spinner-border-sm me-2"></div> Cargando alumnos...
                                        </div>
                                        <div id="tabla_<?php echo $s['id_seccion']; ?>" class="d-none"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
        </main>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
// El control de sidebar lo maneja de forma robusta public/js/sidebar.js cargado en sidebar.view.tpl

const _loaded = new Set();

function cargarAlumnos(btn) {
    const id = btn.getAttribute('data-id-seccion');
    if (_loaded.has(id)) return;
    _loaded.add(id);

    fetch('index.php?page=notas_alumnos_ajax&id_seccion=' + id)
        .then(r => r.json())
        .then(data => {
            const loader = document.getElementById('loader_' + id);
            const tabla  = document.getElementById('tabla_' + id);
            if (!data.alumnos || data.alumnos.length === 0) {
                loader.innerHTML = '<div class="text-center py-4 text-muted"><i class="bi bi-people fs-2 d-block mb-2"></i>No hay alumnos inscritos.</div>';
                return;
            }
            let html = '<div class="table-responsive px-4 pb-4 pt-2"><table class="table table-hover align-middle">'
                + '<thead class="table-light"><tr><th>Estudiante</th><th class="text-center">Cuenta</th>'
                + '<th class="text-center" style="min-width:95px">I Parcial</th>'
                + '<th class="text-center" style="min-width:95px">II Parcial</th>'
                + '<th class="text-center" style="min-width:95px">III Parcial</th>'
                + '<th class="text-center">Promedio</th>'
                + '<th class="text-center">Accion</th></tr></thead><tbody>';

            data.alumnos.forEach(a => {
                const p1  = a.nota_parcial1 !== null ? a.nota_parcial1 : '';
                const p2  = a.nota_parcial2 !== null ? a.nota_parcial2 : '';
                const p3  = a.nota_parcial3 !== null ? a.nota_parcial3 : '';
                const pr  = a.promedio !== null ? parseFloat(a.promedio) : null;
                const prHtml = pr !== null
                    ? '<span class="fw-bold ' + (pr >= 70 ? 'text-success':'text-danger') + '">' + pr.toFixed(2) + '%</span>'
                    : '<span class="text-muted small">pendiente</span>';
                html += '<tr><td><div class="fw-semibold">' + esc(a.nombre_estudiante) + '</div></td>'
                    + '<td class="text-center text-muted small">' + esc(a.numero_cuenta) + '</td>'
                    + mkInput('p1', a.id_matricula, p1)
                    + mkInput('p2', a.id_matricula, p2)
                    + mkInput('p3', a.id_matricula, p3)
                    + '<td class="promedio-cell" id="prom_' + a.id_matricula + '">' + prHtml + '</td>'
                    + '<td class="text-center"><div class="d-flex gap-1 justify-content-center flex-wrap"><button class="btn btn-sm btn-success" id="btn_' + a.id_matricula
                    + '" onclick="guardar(\'' + a.id_matricula + '\')"><i class="bi bi-save me-1"></i>Guardar</button>'
                    + (a.id_calificacion ? '<button class="btn btn-sm btn-outline-warning" data-cal="' + a.id_calificacion + '" data-mat="' + a.id_matricula + '" onclick="solicitarCorreccion(this.dataset.cal,this.dataset.mat)"><i class="bi bi-pencil-square me-1"></i>Correccion</button>' : '')
                    + '</div></td></tr>';
            });
            html += '</tbody></table></div>';
            tabla.innerHTML = html;
            loader.classList.add('d-none');
            tabla.classList.remove('d-none');
        })
        .catch(() => {
            document.getElementById('loader_' + id).innerHTML = '<div class="alert alert-danger mx-4 my-3">Error al cargar alumnos.</div>';
        });
}

function mkInput(pref, id, val) {
    return '<td class="text-center"><input type="number" class="nota-input" id="' + pref + '_' + id
        + '" min="0" max="100" step="0.01" placeholder="0-100" value="' + val
        + '" oninput="calcProm(\'' + id + '\')" onblur="validar(this)"></td>';
}

function calcProm(id) {
    const vals = ['p1_','p2_','p3_'].map(p => parseFloat(document.getElementById(p+id)?.value)).filter(v => !isNaN(v));
    const el = document.getElementById('prom_' + id);
    if (vals.length === 0) { el.innerHTML = '<span class="text-muted small">pendiente</span>'; return; }
    const p = vals.reduce((a,b)=>a+b,0) / vals.length;
    el.innerHTML = '<span class="fw-bold ' + (p>=70?'text-success':'text-danger') + '">' + p.toFixed(2) + '%</span>';
}

function validar(inp) {
    const v = parseFloat(inp.value);
    if (inp.value === '') { inp.classList.remove('is-invalid'); return true; }
    if (isNaN(v) || v < 0 || v > 100) {
        inp.classList.add('is-invalid');
        inp.value = Math.min(100, Math.max(0, v || 0));
        return false;
    }
    inp.classList.remove('is-invalid');
    return true;
}

function guardar(id) {
    const inputs = ['p1_','p2_','p3_'].map(p => document.getElementById(p+id));
    if (!inputs.every(i => i.value === '' || validar(i))) {
        Swal.fire({ icon:'warning', title:'Nota invalida', text:'Las notas deben ser valores entre 0 y 100.', confirmButtonColor:'#0057d8' });
        return;
    }
    const [p1,p2,p3] = inputs.map(i => i.value !== '' ? parseFloat(i.value) : null);
    if (p1===null && p2===null && p3===null) {
        Swal.fire({ icon:'info', title:'Sin datos', text:'Ingrese al menos una nota parcial.', confirmButtonColor:'#0057d8' });
        return;
    }
    const btn = document.getElementById('btn_' + id);
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Guardando...';
    const fd = new FormData();
    fd.append('id_matricula', id);
    if (p1 !== null) fd.append('parcial1', p1);
    if (p2 !== null) fd.append('parcial2', p2);
    if (p3 !== null) fd.append('parcial3', p3);
    fetch('index.php?page=guardar_nota_parciales', { method:'POST', body:fd })
        .then(r => r.json())
        .then(data => {
            if (data.exito) {
                btn.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i>Guardado';
                btn.classList.replace('btn-success','btn-outline-success');
                if (data.promedio !== null) {
                    const c = data.promedio >= 70 ? 'text-success':'text-danger';
                    document.getElementById('prom_'+id).innerHTML = '<span class="fw-bold '+c+'">'+parseFloat(data.promedio).toFixed(2)+'%</span>';
                }
                setTimeout(() => { btn.innerHTML='<i class="bi bi-save me-1"></i>Guardar'; btn.classList.replace('btn-outline-success','btn-success'); btn.disabled=false; }, 3000);
            } else {
                btn.disabled=false; btn.innerHTML='<i class="bi bi-save me-1"></i>Guardar';
                Swal.fire({ icon:'error', title:'Error', text: data.mensaje || 'Intente nuevamente.', confirmButtonColor:'#0057d8' });
            }
        })
        .catch(() => {
            btn.disabled=false; btn.innerHTML='<i class="bi bi-save me-1"></i>Guardar';
            Swal.fire({ icon:'error', title:'Error de conexion', text:'No se pudo conectar.', confirmButtonColor:'#0057d8' });
        });
}

async function solicitarCorreccion(idCalificacion, idMatricula) {
    const p1 = document.getElementById('p1_' + idMatricula)?.value || '';
    const p2 = document.getElementById('p2_' + idMatricula)?.value || '';
    const p3 = document.getElementById('p3_' + idMatricula)?.value || '';
    const res = await Swal.fire({
        icon: 'question',
        title: 'Solicitar correccion de nota',
        input: 'textarea',
        inputLabel: 'Motivo de la correccion',
        inputPlaceholder: 'Explique por que debe ajustarse la nota...',
        showCancelButton: true,
        confirmButtonText: 'Enviar solicitud',
        cancelButtonText: 'Cancelar',
        confirmButtonColor: '#0057d8',
        inputValidator: value => !value ? 'Debe indicar el motivo.' : undefined
    });
    if (!res.isConfirmed) return;

    const form = document.createElement('form');
    form.method = 'POST';
    form.action = 'index.php?page=solicitar_correccion_nota';
    const fields = {
        id_calificacion: idCalificacion,
        parcial1: p1,
        parcial2: p2,
        parcial3: p3,
        motivo: res.value
    };
    Object.entries(fields).forEach(([name, value]) => {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = name;
        input.value = value;
        form.appendChild(input);
    });
    document.body.appendChild(form);
    form.submit();
}

function esc(s) { return s ? String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;') : ''; }

// Auto-expandir la sección si se pasa un id_seccion por GET
window.addEventListener('load', function() {
    <?php if (isset($_GET['id_seccion'])): ?>
    const targetId = <?php echo json_encode("sec_" . $_GET['id_seccion']); ?>;
    const collapseEl = document.getElementById(targetId);
    if (collapseEl) {
        // Inicializar collapse y mostrarlo
        const bsCollapse = new bootstrap.Collapse(collapseEl, { show: true });
        const btn = document.querySelector('[data-bs-target="#' + targetId + '"]');
        if (btn) {
            cargarAlumnos(btn);
        }
    }
    <?php endif; ?>
});
</script>
</body>
</html>
