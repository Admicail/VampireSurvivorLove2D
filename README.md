# VampireSurvivorLove2D

Prototipo de un juego estilo Vampire Survivors desarrollado con el motor **Love2D** y **Lua**.

## Requisitos

- [Love2D](https://love2d.org/) v11.4 o superior

## Cómo ejecutar

```bash
love .
```

(Ejecutar desde la raíz del repositorio)

## Controles

| Tecla | Acción |
|-------|--------|
| W / ↑ | Mover arriba |
| S / ↓ | Mover abajo |
| A / ← | Mover izquierda |
| D / → | Mover derecha |
| R | Reiniciar (tras Game Over) |
| Escape | Salir |

## Mecánicas implementadas

- **Jugador** – movimiento libre por el mapa con colisiones en los bordes.
- **Oleadas de enemigos** – cada 30 segundos llega una nueva oleada con más enemigos y mayor dificultad. Los enemigos persiguen al jugador.
- **Arma automática** – el jugador dispara proyectiles al enemigo más cercano sin necesidad de apuntar manualmente.
- **Sistema de experiencia y niveles** – al eliminar enemigos se gana experiencia. Al subir de nivel se mejora el daño y la cadencia de disparo.
- **Puntuación** – acumula puntos por cada enemigo derrotado.
- **Game Over y reinicio** – al morir aparece la pantalla de fin de partida con la puntuación final.

## Estructura del proyecto

```
main.lua          – Punto de entrada de Love2D
conf.lua          – Configuración de ventana
src/
  game.lua        – Gestión del estado de juego
  player.lua      – Lógica del jugador
  enemy.lua       – Lógica de enemigos
  weapon.lua      – Proyectiles y arma automática
```