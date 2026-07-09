/**
 * sidebar.js — Control dinámico y robusto del sidebar
 * Crea dinámicamente el botón de hamburguesa si no existe,
 * y maneja la visibilidad e interactividad en todas las vistas de forma centralizada.
 */
(function () {
    function initSidebar() {
        var sidebar = document.querySelector('.sidebar');
        var main    = document.querySelector('main') || document.querySelector('.col-md-10') || document.querySelector('[role="main"]');

        if (!sidebar) return;

        // 1. Asegurar que existe el botón de hamburguesa en el contenido principal
        var hamburguesa = document.getElementById('toggleSidebarHeader');
        if (!hamburguesa && main) {
            hamburguesa = document.createElement('button');
            hamburguesa.id = 'toggleSidebarHeader';
            hamburguesa.className = 'btn btn-sm btn-outline-secondary toggleSidebarBtn me-3 mb-3';
            hamburguesa.type = 'button';
            hamburguesa.innerHTML = '<i class="bi bi-list"></i>';
            hamburguesa.style.marginTop = '4px';

            // Insertar al inicio del contenedor principal
            main.insertBefore(hamburguesa, main.firstChild);
        }

        // 2. Función para actualizar el estado visual
        function actualizarEstado() {
            var isCollapsed = sidebar.classList.contains('collapsed');

            if (isCollapsed) {
                // Colapsado: ocultar barra y expandir contenido
                sidebar.style.setProperty('display', 'none', 'important');
                if (main) {
                    main.classList.remove('col-md-10', 'col-lg-10');
                    main.classList.add('col-md-12', 'col-lg-12');
                }
                if (hamburguesa) {
                    hamburguesa.style.setProperty('display', 'inline-block', 'important');
                }
            } else {
                // Expandido: mostrar barra y reducir contenido
                sidebar.style.setProperty('display', 'block', 'important');
                if (main) {
                    main.classList.remove('col-md-12', 'col-lg-12');
                    main.classList.add('col-md-10', 'col-lg-10');
                }
                if (hamburguesa) {
                    hamburguesa.style.setProperty('display', 'none', 'important');
                }
            }
        }

        // 3. Registrar el evento de clic mediante delegación para mayor robustez
        document.addEventListener('click', function (e) {
            var btn = e.target.closest('.toggleSidebarBtn');
            if (btn) {
                sidebar.classList.toggle('collapsed');
                actualizarEstado();
            }
        });

        // Inicializar
        actualizarEstado();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSidebar);
    } else {
        initSidebar();
    }
})();
