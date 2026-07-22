/**
 * confirmaciones.js — Manejador global de confirmaciones SweetAlert2
 * Captura clics en elementos y envíos de formularios con atributos 'data-confirmar'
 * y muestra alertas personalizadas y premium de forma centralizada.
 */
document.addEventListener('DOMContentLoaded', function () {
    // 1. Delegación de eventos para enlaces y botones con data-confirmar
    document.addEventListener('click', function (e) {
        var element = e.target.closest('[data-confirmar]');
        if (!element) return;

        // Si es un formulario o un botón de submit, lo gestiona el listener de submit
        if (element.tagName === 'FORM' || (element.tagName === 'BUTTON' && element.type === 'submit')) {
            return;
        }

        e.preventDefault();

        var mensaje = element.getAttribute('data-confirmar');
        var titulo = element.getAttribute('data-titulo') || '¿Está seguro?';
        var icono = element.getAttribute('data-icono') || 'warning';
        var botonConfirmar = element.getAttribute('data-confirm-text') || 'Sí, continuar';
        var href = element.getAttribute('href');

        Swal.fire({
            title: titulo,
            text: mensaje,
            icon: icono,
            showCancelButton: true,
            confirmButtonColor: '#0057d8',
            cancelButtonColor: '#64748b',
            confirmButtonText: botonConfirmar,
            cancelButtonText: 'Cancelar',
            customClass: {
                popup: 'rounded-4 shadow',
                confirmButton: 'px-4 py-2 font-weight-bold',
                cancelButton: 'px-4 py-2'
            }
        }).then(function (result) {
            if (result.isConfirmed && href) {
                window.location.href = href;
            }
        });
    });

    // 2. Delegación de eventos para envíos de formularios con data-confirmar
    document.addEventListener('submit', function (e) {
        var form = e.target;
        var mensaje = form.getAttribute('data-confirmar');
        
        // Si el formulario no tiene data-confirmar, buscar si el botón presionado lo tiene
        var submitter = e.submitter;
        if (!mensaje && submitter) {
            mensaje = submitter.getAttribute('data-confirmar');
        }

        if (!mensaje) return;

        e.preventDefault();

        var titulo = (submitter && submitter.getAttribute('data-titulo')) || form.getAttribute('data-titulo') || '¿Está seguro?';
        var icono = (submitter && submitter.getAttribute('data-icono')) || form.getAttribute('data-icono') || 'warning';
        var botonConfirmar = (submitter && submitter.getAttribute('data-confirm-text')) || form.getAttribute('data-confirm-text') || 'Sí, continuar';

        Swal.fire({
            title: titulo,
            text: mensaje,
            icon: icono,
            showCancelButton: true,
            confirmButtonColor: '#0057d8',
            cancelButtonColor: '#64748b',
            confirmButtonText: botonConfirmar,
            cancelButtonText: 'Cancelar',
            customClass: {
                popup: 'rounded-4 shadow',
                confirmButton: 'px-4 py-2 font-weight-bold',
                cancelButton: 'px-4 py-2'
            }
        }).then(function (result) {
            if (result.isConfirmed) {
                // Desactivar temporalmente el listener para enviar el formulario
                form.removeAttribute('data-confirmar');
                if (submitter) submitter.removeAttribute('data-confirmar');
                form.submit();
            }
        });
    });
});
