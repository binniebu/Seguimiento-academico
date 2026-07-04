<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flujograma - <?php echo htmlspecialchars($carrera['nombre_carrera']); ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
    <style>
        .flujograma-container {
            display: flex;
            flex-direction: column;
            gap: 2rem;
            padding-bottom: 3rem;
        }
        .materia-card {
            border-left: 4px solid #0d6efd;
            transition: transform 0.2s, box-shadow 0.2s;
            height: 100%;
        }
        .materia-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important;
        }
        .materia-institucional { border-left-color: #6c757d; }
        .materia-facultad { border-left-color: #0dcaf0; }
        .materia-carrera { border-left-color: #198754; }
        
        .requisito-badge {
            font-size: 0.75rem;
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
            padding: 4px 8px;
            border-radius: 4px;
            display: inline-block;
            margin-top: 8px;
        }
        
        .periodo-header {
            background-color: #f8f9fa;
            border-left: 5px solid #0d6efd;
            padding: 10px 15px;
            border-radius: 4px;
            margin-bottom: 1.5rem;
            font-weight: bold;
            color: #495057;
            display: flex;
            align-items: center;
            gap: 10px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

            <!-- Main content -->
            <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div>
                        <h1 class="h2 page-title mb-0">Flujograma Académico</h1>
                        <p class="text-muted mb-0 fs-5"><?php echo htmlspecialchars($carrera['nombre_carrera']); ?></p>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="index.php?page=carreras" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left"></i> Volver a Carreras
                        </a>
                        <a href="index.php?page=materia_nueva&id_carrera_pre=<?php echo $carrera['id_carrera']; ?>" class="btn btn-primary">
                            <i class="bi bi-plus-circle"></i> Agregar Materia
                        </a>
                    </div>
                </div>

                <?php
                // Agrupar materias por periodo
                $periodos = [];
                $inst = [];
                $fac = [];
                $car = [];
                
                foreach ($materias as $m) {
                    $p = intval($m['periodo'] ?? 1);
                    if (!isset($periodos[$p])) {
                        $periodos[$p] = [];
                    }
                    $periodos[$p][] = $m;
                    
                    if ($m['tipo_materia'] === 'institucional') $inst[] = $m;
                    elseif ($m['tipo_materia'] === 'facultad') $fac[] = $m;
                    elseif ($m['tipo_materia'] === 'carrera') $car[] = $m;
                }
                ksort($periodos);
                ?>

                <div class="flujograma-container">
                    
                    <!-- Buscador -->
                    <?php if (!empty($materias)): ?>
                    <div class="row mb-2">
                        <div class="col-md-5">
                            <div class="input-group shadow-sm">
                                <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                                <input type="text" id="buscadorFlujograma" class="form-control border-start-0" placeholder="Buscar clase por nombre o código...">
                            </div>
                        </div>
                    </div>
                    
                    <!-- Contadores Estadísticos -->
                    <div class="row g-3 mb-4">
                        <div class="col-6 col-md-3">
                            <div class="card bg-light border-0 shadow-sm text-center py-2 h-100">
                                <h6 class="text-secondary mb-1" style="font-size: 0.8rem; text-transform: uppercase;">Institucionales</h6>
                                <span class="fs-4 fw-bold text-dark"><?php echo count($inst); ?></span>
                            </div>
                        </div>
                        <div class="col-6 col-md-3">
                            <div class="card bg-light border-0 shadow-sm text-center py-2 h-100">
                                <h6 class="text-info mb-1" style="font-size: 0.8rem; text-transform: uppercase;">De Facultad</h6>
                                <span class="fs-4 fw-bold text-dark"><?php echo count($fac); ?></span>
                            </div>
                        </div>
                        <div class="col-6 col-md-3">
                            <div class="card bg-light border-0 shadow-sm text-center py-2 h-100">
                                <h6 class="text-success mb-1" style="font-size: 0.8rem; text-transform: uppercase;">De Carrera</h6>
                                <span class="fs-4 fw-bold text-dark"><?php echo count($car); ?></span>
                            </div>
                        </div>
                        <div class="col-6 col-md-3">
                            <div class="card bg-primary text-white border-0 shadow-sm text-center py-2 h-100">
                                <h6 class="mb-1 text-white-50" style="font-size: 0.8rem; text-transform: uppercase;">Total Clases</h6>
                                <span class="fs-4 fw-bold"><?php echo count($materias); ?></span>
                            </div>
                        </div>
                    </div>
                    <?php endif; ?>

                    <?php if (empty($materias)): ?>
                        <div class="alert alert-warning text-center p-5 shadow-sm rounded-4">
                            <i class="bi bi-diagram-3 text-warning mb-3" style="font-size: 3rem;"></i>
                            <h4>Flujograma Vacío</h4>
                            <p class="text-muted">Esta carrera aún no tiene materias asignadas. El estado de la carrera permanecerá como "Pendiente de carga académica".</p>
                            <a href="index.php?page=materia_nueva&id_carrera_pre=<?php echo $carrera['id_carrera']; ?>" class="btn btn-primary mt-2">
                                Comenzar a agregar clases
                            </a>
                        </div>
                    <?php else: ?>

                        <?php foreach ($periodos as $numero => $materiasPeriodo): ?>
                            <div class="flujograma-seccion">
                                <div class="periodo-header shadow-sm">
                                    <i class="bi bi-calendar3"></i> Periodo Sugerido <?php echo $numero; ?>
                                </div>
                                <div class="row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4">
                                    <?php foreach ($materiasPeriodo as $m): 
                                        $claseColor = 'materia-institucional';
                                        $badgeColor = 'bg-secondary';
                                        if ($m['tipo_materia'] === 'facultad') {
                                            $claseColor = 'materia-facultad';
                                            $badgeColor = 'bg-info text-dark';
                                        } elseif ($m['tipo_materia'] === 'carrera') {
                                            $claseColor = 'materia-carrera';
                                            $badgeColor = 'bg-success';
                                        }
                                    ?>
                                        <div class="col">
                                            <div class="card materia-card <?php echo $claseColor; ?> shadow-sm">
                                                <div class="card-body">
                                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                                        <span class="badge <?php echo $badgeColor; ?>"><?php echo htmlspecialchars($m['codigo']); ?></span>
                                                        <span class="badge bg-light text-dark border"><?php echo $m['creditos']; ?> UV</span>
                                                    </div>
                                                    <h5 class="card-title text-dark fw-bold mb-1"><?php echo htmlspecialchars($m['nombre']); ?></h5>
                                                    <?php if (!empty($m['nombre_requisito'])): ?>
                                                        <div class="requisito-badge">
                                                            <i class="bi bi-lock-fill"></i> Req: <?php echo htmlspecialchars($m['nombre_requisito']); ?>
                                                        </div>
                                                    <?php endif; ?>
                                                </div>
                                                <div class="card-footer bg-transparent border-0 pt-0 text-end">
                                                    <a href="index.php?page=materia_nueva&id=<?php echo $m['id_materia']; ?>&id_carrera_pre=<?php echo $carrera['id_carrera']; ?>" class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i> Editar</a>
                                                </div>
                                            </div>
                                        </div>
                                    <?php endforeach; ?>
                                </div>
                            </div>
                        <?php endforeach; ?>

                    <?php endif; ?>

                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    document.getElementById('buscadorFlujograma')?.addEventListener('keyup', function() {
        const term = this.value.toLowerCase();
        const cols = document.querySelectorAll('.flujograma-seccion .col');
        
        cols.forEach(col => {
            const title = col.querySelector('.card-title')?.textContent.toLowerCase() || '';
            const badge = col.querySelector('.badge')?.textContent.toLowerCase() || '';
            
            if (title.includes(term) || badge.includes(term)) {
                col.style.display = '';
            } else {
                col.style.display = 'none';
            }
        });
        
        // Hide empty sections
        document.querySelectorAll('.flujograma-seccion').forEach(sec => {
            const visibleCols = Array.from(sec.querySelectorAll('.col')).filter(c => c.style.display !== 'none');
            if (visibleCols.length === 0) {
                sec.style.display = 'none';
            } else {
                sec.style.display = '';
            }
        });
    });
    </script>
</body>
</html>
