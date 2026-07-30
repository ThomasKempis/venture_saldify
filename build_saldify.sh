#!/bin/bash
# 1. Limpieza inicial
echo "🧹 Limpiando build anterior..."
rm -rf build/web

echo "🚀 Iniciando proceso para SALDIFY..."
echo "📦 Compilando aplicación..."
flutter build web --base-href "/venture_saldify/" --dart-define=APP_MODE=saldify --release

if [ $? -eq 0 ]; then
    echo "✅ Compilación exitosa. Iniciando personalización de marca..."

    echo "🧹 Retirando parche exclusivo de desarrollo..."
    sed -i '' '/<!-- DEV_PATCH_START -->/,/<!-- DEV_PATCH_END -->/d' build/web/index.html

    # Variables de marca
    APP_TITLE="Saldify"
    APP_TITLE_UPPER="SALDIFY"
    APP_DESCRIPTION="Red de venta para gestión de créditos y saldos en línea"
    APP_BACKGROUND="linear-gradient(180deg, #155C37 0%, #1B5E20 26%, #0D47A1 100%)"
    APP_BOTTOM_COLOR="#0D47A1"
    APP_LOGO_ANIMATION="spinContinuous 4s linear infinite"

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

    echo "🖼️  Aplicando iconos de PWA (Saldify):"
    cp -v web/icons/saldify/* build/web/icons/

    echo "🧹 Limpiando directorios de marca del paquete final..."
    rm -rf build/web/icons/saldify
    rm -rf build/web/icons/redcontrol

    if [ -f "web/icons/saldify/favicon.png" ]; then
        cp -fv "web/icons/saldify/favicon.png" "build/web/favicon.png"
        echo "🎨 Favicon oficial copiado a la raíz (/favicon.png)."
    fi

    echo "📚 Preparando documentación HTML..."
    rm -rf build/web/htmls
    cp -R documents/htmls build/web/htmls
    cp -fv build/web/htmls/docu.html build/web/docu.html
    rm -f build/web/htmls/docu.html
    sed -i '' 's|href="docu_|href="htmls/docu_|g' build/web/docu.html
    sed -i '' 's|../../assets/images/saldify/logo.png|assets/assets/images/saldify/logo.png|g' build/web/docu.html
    sed -i '' "s|'../assets/images/saldify/logo.png'|'../assets/assets/images/saldify/logo.png'|g" build/web/htmls/docu_shell.js

    echo "📚 Documentación lista en /docu.html y /htmls/."

    echo "✨ ¡Branding aplicado correctamente!"
    echo "🏁 Todo listo en: build/web/"
else
    echo "❌ Error: La compilación de Flutter falló. No se aplicaron los cambios de marca."
    exit 1
fi
