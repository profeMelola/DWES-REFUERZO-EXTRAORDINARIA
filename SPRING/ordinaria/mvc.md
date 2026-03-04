# EventHubMVC

Usuarios de prueba: 

- Username: user@demo · Email: user@demo.local · Pwd: user123
- Username: admin@local · Email: admin@demo.local · Pwd: admin123

## 1. Securizar la aplicación

Debes securizar la aplicación para que cualquier página de la aplicación requiera autenticación (excepto la página de login y recursos estáticos necesarios).

Modifica el proceso de autenticación para que un usuario pueda iniciar sesión utilizando su nombre de usuario o su email (ambos deben funcionar). 

Debe ser posible iniciar sesión tanto con el Username como con el Email de los usuarios de prueba.

![alt text](image-4.png)

## 2. Edición de perfil

Implementa una funcionalidad “Editar usuario” que permita a un usuario autenticado modificar los datos de su perfil desde la aplicación web. Se editarán únicamente fullName, email y password.

La solución debe estar integrada en el flujo MVC existente y cumplir los siguientes criterios:

- Debe añadirse un acceso a esta funcionalidad desde la interfaz cuando el usuario esté autenticado (en el menú).
- Los datos actuales del usuario deben mostrarse en el formulario de edición. Utiliza y amplía profile/edit.html

![alt text](image-5.png)


- La contraseña solo debe modificarse si el usuario decide cambiarla.
- Al cargarse el formulario de edición aparecerá solo el nombre completo y el email, las contraseñas no aparecen visibles. Observa la captura.

Tras una actualización correcta, el usuario debe ser redirigido al formulario indicando que se ha actualizado correctamente el perfil.



### Validaciones

- El nombre completo y el email deben validarse correctamente, acorde a las restricciones del modelo.
- Implementa todas las validaciones que puedes ver en la captura de pantalla.
- El email no puede coincidir con el de otro usuario del sistema.
- Los errores de validación deben mostrarse en el formulario acorde a las capturas de pantalla.

![alt text](image-6.png)