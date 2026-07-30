#!/bin/bash
# 1. Limpieza inicial
echo "🧹 Limpiando build anterior..."
rm -rf build/web

echo "🚀 Iniciando proceso para REDVENTAS..."
echo "📦 Compilando aplicación..."
flutter build web --base-href "/redVentas/" --dart-define=APP_MODE=redventas --release

if [ $? -eq 0 ]; then
    echo "✅ Compilación exitosa. Iniciando personalización de marca..."

    echo "🧹 Retirando parche exclusivo de desarrollo..."
    sed -i '' '/<!-- DEV_PATCH_START -->/,/<!-- DEV_PATCH_END -->/d' build/web/index.html

    # Variables de marca
    APP_TITLE="RedVentas"
    APP_TITLE_UPPER="REDVENTAS"
    APP_DESCRIPTION="CONECTA + GESTIONA + CRECE"
    APP_BACKGROUND="linear-gradient(160deg, #0D9488 0%, #238D82 42%, #E63946 100%)"
    APP_BOTTOM_COLOR="#B65F77"
    APP_LOGO_ANIMATION="fadeLogo 2.8s ease-in-out infinite"

    echo "📝 Inyectando textos en index.html..."
    sed -i '' "s/{{APP_TITLE}}/$APP_TITLE/g" build/web/index.html
    sed -i '' "s/{{APP_TITLE_UPPER}}/$APP_TITLE_UPPER/g" build/web/index.html
    sed -i '' "s/{{APP_DESCRIPTION}}/$APP_DESCRIPTION/g" build/web/index.html
    sed -i '' "s|{{APP_BACKGROUND}}|$APP_BACKGROUND|g" build/web/index.html
    sed -i '' "s|{{APP_BOTTOM_COLOR}}|$APP_BOTTOM_COLOR|g" build/web/index.html
    sed -i '' "s|{{APP_LOGO_ANIMATION}}|$APP_LOGO_ANIMATION|g" build/web/index.html

    echo "📝 Inyectando textos en manifest.json..."
    sed -i '' "s/{{APP_TITLE}}/$APP_TITLE/g" build/web/manifest.json
    sed -i '' "s/{{APP_DESCRIPTION}}/$APP_DESCRIPTION/g" build/web/manifest.json

    echo "🖼️  Aplicando iconos de PWA (RedVentas):"
    cp -v web/icons/redventas/* build/web/icons/

    echo "🧹 Limpiando directorios de marca del paquete final..."
    rm -rf build/web/icons/saldify
    rm -rf build/web/icons/redventas

    if [ -f "web/icons/redventas/favicon.png" ]; then
        cp -fv "web/icons/redventas/favicon.png" "build/web/favicon.png"
        echo "🎨 Favicon oficial copiado a la raíz (/favicon.png)."
    fi

    echo "📚 Preparando documentación HTML..."
    rm -rf build/web/htmls
    cp -R documents/htmls build/web/htmls
    cp -fv build/web/htmls/docu.html build/web/docu.html
    rm -f build/web/htmls/docu.html
    sed -i '' 's|href="docu_|href="htmls/docu_|g' build/web/docu.html
    sed -i '' 's|../../assets/images/saldify/logo.png|assets/assets/images/redventas/logo.png|g' build/web/docu.html
    sed -i '' 's|assets/images/saldify/logo.png|assets/images/redventas/logo.png|g' build/web/htmls/docu_shell.js
    sed -i '' "s|'../assets/images/redventas/logo.png'|'../assets/assets/images/redventas/logo.png'|g" build/web/htmls/docu_shell.js

    echo "📝 Aplicando nombre RedVentas en la documentación..."
    find build/web/htmls -type f \( -name '*.html' -o -name '*.js' \) -exec sed -i '' \
        -e "s/Saldify Docs/$APP_TITLE_UPPER DOCS/g" \
        -e "s/Documento Saldify/DOCUMENTO $APP_TITLE_UPPER/g" \
        -e "s/SaldiFY/$APP_TITLE/g" \
        -e "s/Saldify/$APP_TITLE/g" \
        -e "s/SALDIFY/$APP_TITLE_UPPER/g" {} +
    sed -i '' \
        -e "s/SaldiFY/$APP_TITLE/g" \
        -e "s/Saldify/$APP_TITLE/g" \
        -e "s/SALDIFY/$APP_TITLE_UPPER/g" build/web/docu.html
    echo "📚 Documentación lista en /docu.html y /htmls/."

    echo "✨ ¡Branding aplicado correctamente!"
    echo "🏁 Todo listo en: build/web/"
else
    echo "❌ Error: La compilación de Flutter falló. No se aplicaron los cambios de marca."
    exit 1
fi
