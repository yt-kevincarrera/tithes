# Publicar una versión

La app se actualiza sola desde las releases de este repositorio, así que
publicar una versión es todo el proceso de despliegue que hay.

## Publicar

1. Sube el número en `pubspec.yaml`:

   ```yaml
   version: 1.1.0+2
   ```

   `1.1.0` es lo que compara el actualizador; `+2` es el `versionCode` de
   Android, que **tiene que crecer siempre** o el sistema rechaza la
   instalación.

2. Etiqueta y empuja:

   ```bash
   git commit -am "v1.1.0" && git tag v1.1.0 && git push origin main --tags
   ```

El workflow de `.github/workflows/release.yml` corre los tests, compila el APK
firmado, crea la release y le adjunta `diezmo-1.1.0.apk`. La próxima vez que
abras la app, el aviso aparece solo.

La etiqueta tiene que coincidir con la versión de `pubspec.yaml`: el
actualizador compara `tag_name` contra la versión instalada.

## Lo que hay configurado en GitHub

Secrets del repositorio:

| Secret | Qué es |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `android/diezmo-release.jks` en base64 |
| `ANDROID_KEYSTORE_PASSWORD` | contraseña del almacén |
| `ANDROID_KEY_ALIAS` | `diezmo` |
| `ANDROID_KEY_PASSWORD` | contraseña de la clave |

Variable del repositorio:

| Variable | Qué es |
| --- | --- |
| `RATES_ENDPOINT` | URL del proxy de tasas, p. ej. `https://…/api/rates` |

Si `RATES_ENDPOINT` está vacía la app compila igual; la dirección se puede poner
después desde Ajustes, dentro del teléfono.

## La clave de firma

Está en `android/diezmo-release.jks` y **no está en git**. La contraseña está en
`android/key.properties`, que tampoco.

Android solo permite actualizar una app en sitio si el APK nuevo lleva la misma
firma que el instalado. **Si pierdes esa clave, no puedes volver a publicar una
actualización nunca más**: la única salida sería desinstalar la app, lo que se
lleva por delante todos tus datos.

Guarda una copia del `.jks` y de la contraseña fuera de esta máquina.

## Compilar a mano

```bash
flutter build apk --release
```

Sale firmado con la clave de release si `android/key.properties` existe. Si no,
cae a la clave de debug para que se pueda probar en cualquier máquina — pero ese
APK **no** sirve para actualizar uno instalado desde una release.
