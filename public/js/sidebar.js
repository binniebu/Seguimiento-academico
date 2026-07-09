/**
 * sidebar.js — Control responsivo e interactivo del sidebar
 * Maneja la visibilidad de la barra lateral en móviles mediante drawer y overlay,
 * y el colapso de columna en escritorios.
 */
(function () {
    function initSidebar() {
        var sidebar = document.querySelector('.sidebar');
        var main    = document.querySelector('main') || document.querySelector('.col-md-10') || document.querySelector('[role="main"]');

        if (!sidebar) return;

        // 1. Crear overlay de fondo para móviles si no existe
        var overlay = document.querySelector('.sidebar-overlay');
        if (!overlay) {
            overlay = document.createElement('div');
            overlay.className = 'sidebar-overlay';
            document.body.appendChild(overlay);
        }

        // 2. Función para actualizar visualización según tamaño de pantalla
        function actualizarEstado() {
            var esMovil = window.innerWidth < 768;
            var isCollapsed = sidebar.classList.contains('collapsed');

            if (esMovil) {
                // Modo Móvil: quitar clases y estilos de escritorio
                sidebar.style.removeProperty('display');
                if (main) {
                    main.classList.remove('col-md-10', 'col-lg-10');
                    main.classList.add('col-md-12', 'col-lg-12');
                }
                
                // Controlar por clase show (drawer flotante)
                if (sidebar.classList.contains('show')) {
                    overlay.style.display = 'block';
                    document.body.style.overflow = 'hidden'; // Evitar scroll
                } else {
                    overlay.style.display = 'none';
                    document.body.style.overflow = '';
                }
            } else {
                // Modo Escritorio: restaurar scroll y ocultar overlay
                overlay.style.display = 'none';
                document.body.style.overflow = '';

                if (isCollapsed) {
                    sidebar.style.setProperty('display', 'none', 'important');
                    if (main) {
                        main.classList.remove('col-md-10', 'col-lg-10');
                        main.classList.add('col-md-12', 'col-lg-12');
                    }
                } else {
                    sidebar.style.setProperty('display', 'block', 'important');
                    if (main) {
                        main.classList.remove('col-md-12', 'col-lg-12');
                        main.classList.add('col-md-10', 'col-lg-10');
                    }
                }
            }
        }

        // 3. Registrar eventos de clic para alternar el menú
        document.addEventListener('click', function (e) {
            var btn = e.target.closest('.toggleSidebarBtn');
            var clickedOverlay = e.target.closest('.sidebar-overlay');
            
            if (btn) {
                var esMovil = window.innerWidth < 768;
                if (esMovil) {
                    sidebar.classList.toggle('show');
                } else {
                    sidebar.classList.toggle('collapsed');
                }
                actualizarEstado();
            } else if (clickedOverlay) {
                // Si hace clic en el fondo oscuro en móviles, cerrar el menú
                sidebar.classList.remove('show');
                actualizarEstado();
            }
        });

        // 4. Escuchar redimensionamiento de pantalla
        window.addEventListener('resize', actualizarEstado);

        // Inicializar
        actualizarEstado();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSidebar);
    } else {
        initSidebar();
    }
})();
