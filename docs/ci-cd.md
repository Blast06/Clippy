# CI/CD: de un push a la app en tu teléfono

```
push a develop
   ├── GitHub Actions  → APK firmado → Firebase App Distribution → App Tester (Android)
   └── Codemagic       → IPA firmado → TestFlight                → TestFlight (iPhone)
push / PR a main o develop → GitHub Actions CI (analyze + test)
```

| Archivo | Qué hace |
|---|---|
| `.github/workflows/ci.yml` | `flutter analyze` + `flutter test` en cada PR y push a `main`/`develop` |
| `.github/workflows/android-distribute.yml` | Push a `develop` → APK firmado → Firebase |
| `codemagic.yaml` | Push a `develop` → IPA firmado → TestFlight |
| `android/app/build.gradle` | Firma release con `android/key.properties` si existe (si no, usa la clave debug) |

---

## 0. Crear la rama `develop`

```sh
git checkout main && git pull
git checkout -b develop && git push -u origin develop
```

## 1. Android: Firebase App Distribution

### 1.1 Proyecto Firebase
1. En <https://console.firebase.google.com> crea un proyecto (p. ej. `clippy`).
2. **Agregar app → Android** con package `com.juliodelgado.clippy`. No hace falta el
   `google-services.json` ni el SDK de Firebase: solo usamos la distribución.
3. Copia el **App ID** (`1:1234567890:android:abc...`) desde *Configuración del proyecto*.
4. *Release & Monitor → App Distribution → Comenzar*. En **Testers & Groups** crea el
   grupo con alias **`testers`** y agrega tu correo.

### 1.2 Cuenta de servicio
1. *Configuración del proyecto → Cuentas de servicio → Administrar permisos en Google Cloud*.
2. Crea una cuenta de servicio con el rol **Firebase App Distribution Admin**.
3. *Claves → Agregar clave → JSON*. Descarga el archivo.

### 1.3 Keystore de firma (una sola vez, guárdalo bien)
```sh
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
base64 -i upload-keystore.jks | tr -d '\n' > keystore.b64   # macOS
```
Si pierdes este keystore, las nuevas builds no se instalarán encima de las anteriores.

### 1.4 Secretos en GitHub
*Repo → Settings → Secrets and variables → Actions → New repository secret*:

| Secreto | Valor |
|---|---|
| `FIREBASE_ANDROID_APP_ID` | App ID del paso 1.1 |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Contenido completo del JSON del paso 1.2 |
| `ANDROID_KEYSTORE_BASE64` | Contenido de `keystore.b64` |
| `ANDROID_KEYSTORE_PASSWORD` | Contraseña del keystore |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | Contraseña de la clave (suele ser la misma) |

Opcional, en la pestaña **Variables**: `CLIPPY_BACKEND_BASE_URL` con la URL de tu n8n.

### 1.5 En el teléfono
Te llega un correo de invitación de Firebase: acéptalo e instala **App Tester**.
Cada build nueva aparece ahí con el mensaje del commit como notas.

---

## 2. iOS: Codemagic → TestFlight

Requiere membresía **Apple Developer Program**. El team actual del proyecto es `S7BNBPHN94`.

### 2.1 App en App Store Connect
1. <https://developer.apple.com/account> → *Identifiers*: confirma o crea `com.juliodelgado.clippy`.
2. <https://appstoreconnect.apple.com> → *Apps → +* → Nueva app con ese bundle ID.
3. En *Información de la app*, copia el **Apple ID** numérico y ponlo en
   `codemagic.yaml` → `APP_STORE_APPLE_ID` (reemplaza `0000000000`).

### 2.2 API key de App Store Connect
*Usuarios y acceso → Integraciones → App Store Connect API → Generar clave*, con rol
**App Manager**. Anota el **Issuer ID** y el **Key ID**, y descarga el `.p8`
(solo se puede descargar una vez).

### 2.3 Codemagic
1. Entra a <https://codemagic.io> con tu cuenta de GitHub y agrega el repo `Blast06/Clippy`.
   Selecciona **codemagic.yaml** como configuración.
2. *Team settings → Integrations → Developer Portal → Connect*: sube la API key y nómbrala
   exactamente **`Clippy ASC Key`** (o cambia el nombre en `codemagic.yaml`).
3. *Team settings → Code signing identities*:
   - **iOS certificates**: *Generate certificate* (tipo Apple Distribution) con esa API key.
   - **iOS provisioning profiles**: *Fetch profiles* y elige el de App Store para
     `com.juliodelgado.clippy` (créalo en developer.apple.com si no aparece).
4. Opcional: *App settings → Environment variables*, crea el grupo `clippy` con
   `CLIPPY_BACKEND_BASE_URL`.
5. En *Webhooks* de la app en Codemagic, confirma que el webhook de GitHub quedó creado
   (así cada push a `develop` dispara el build).

### 2.4 En el iPhone
Instala **TestFlight**. En App Store Connect → *TestFlight → Pruebas internas*, crea un
grupo y agrégate. La primera build puede tardar unos minutos en procesarse; después
cada push a `develop` llega como actualización.

---

## 3. Probar el flujo

```sh
git checkout develop
git commit --allow-empty -m "Trigger test build"
git push
```
- Android: pestaña **Actions** del repo → *Android → Firebase App Distribution*.
- iOS: panel de Codemagic → *iOS → TestFlight*.

## Problemas comunes
- **Android “App not installed”** al actualizar: la build anterior se firmó con otra clave.
  Desinstala la app una vez; desde ahí todas usan el keystore de CI.
- **Codemagic: no matching profiles**: el bundle ID del perfil debe ser exactamente
  `com.juliodelgado.clippy` y de tipo App Store.
- **TestFlight rechaza el número de build**: revisa `APP_STORE_APPLE_ID`; el script toma
  el último build de TestFlight y le suma 1.
- **Falta información de cumplimiento de exportación**: para no tener que responderlo en
  cada build, agrega `ITSAppUsesNonExemptEncryption = NO` en `ios/Runner/Info.plist`
  si la app solo usa HTTPS estándar.
