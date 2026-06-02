<h1>Bienvenido al sistema</h1>

<p>Usuario: <?php echo $_SESSION["usuario"]; ?></p>
<p>Rol: <?php echo $_SESSION["rol"]; ?></p>

<a href="index.php?page=logout">Cerrar sesión</a>