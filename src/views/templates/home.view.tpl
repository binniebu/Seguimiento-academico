<style>
*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:Arial, sans-serif;
}

body{
    background:#f4f6f9;
}

.navbar{
    background:#0d6efd;
    padding:15px 30px;
    display:flex;
    justify-content:space-between;
    align-items:center;
}

.logo{
    color:white;
    font-size:24px;
    font-weight:bold;
}

.menu{
    display:flex;
    gap:18px;
}

.menu a{
    color:white;
    text-decoration:none;
    font-weight:bold;
}

.menu a:hover{
    color:#dbeafe;
}

.hero{
    height:380px;
    display:flex;
    flex-direction:column;
    justify-content:center;
    align-items:center;
    text-align:center;
    background:linear-gradient(to right,#0d6efd,#4f9cff);
    color:white;
}

.hero h1{
    font-size:42px;
    margin-bottom:15px;
}

.hero p{
    font-size:20px;
    width:70%;
}

.cards{
    display:flex;
    justify-content:center;
    flex-wrap:wrap;
    gap:25px;
    padding:50px;
}

.card{
    width:280px;
    background:white;
    border-radius:10px;
    padding:25px;
    box-shadow:0 0 10px rgba(0,0,0,.1);
    text-align:center;
}

.card h3{
    color:#0d6efd;
    margin-bottom:10px;
}

.card p{
    color:#555;
}

.card a{
    display:inline-block;
    margin-top:15px;
    background:#0d6efd;
    color:white;
    padding:10px 18px;
    text-decoration:none;
    border-radius:6px;
}

.card a:hover{
    background:#084298;
}

.footer{
    background:#0d6efd;
    color:white;
    text-align:center;
    padding:15px;
}
</style>

<nav class="navbar">
    <div class="logo">Seguimiento Académico</div>

    <div class="menu">
        <a href="index.php?page=home">Inicio</a>
        <a href="index.php?page=estudiantes">Estudiantes</a>
        <a href="index.php?page=maestros">Maestros</a>
        <a href="index.php?page=materias">Materias</a>
        <a href="index.php?page=matriculas">Matrículas</a>
        <a href="index.php?page=calificaciones">Calificaciones</a>
        <a href="index.php?page=usuarios">Usuarios</a>
    </div>
</nav>

<section class="hero">
    <h1>Sistema de Seguimiento Académico</h1>
    <p>
        Plataforma para administrar estudiantes, maestros, materias,
        matrículas, usuarios y calificaciones.
    </p>
</section>

<section class="cards">

    <div class="card">
        <h3>Estudiantes</h3>
        <p>Administración completa de estudiantes.</p>
        <a href="index.php?page=estudiantes">Entrar</a>
    </div>

    <div class="card">
        <h3>Maestros</h3>
        <p>Registro y control de docentes.</p>
        <a href="index.php?page=maestros">Entrar</a>
    </div>

    <div class="card">
        <h3>Materias</h3>
        <p>Gestión de asignaturas académicas.</p>
        <a href="index.php?page=materias">Entrar</a>
    </div>

    <div class="card">
        <h3>Matrículas</h3>
        <p>Control de inscripción de estudiantes.</p>
        <a href="index.php?page=matriculas">Entrar</a>
    </div>

    <div class="card">
        <h3>Calificaciones</h3>
        <p>Registro de notas y evaluaciones.</p>
        <a href="index.php?page=calificaciones">Entrar</a>
    </div>

    <div class="card">
        <h3>Usuarios</h3>
        <p>Administración de accesos y roles.</p>
        <a href="index.php?page=usuarios">Entrar</a>
    </div>

</section>

<footer class="footer">
    Sistema de Seguimiento Académico
</footer>