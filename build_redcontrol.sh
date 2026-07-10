#!/bin/bash
# 1. Limpieza inicial
echo "🧹 Limpiando build anterior..."
rm -rf build/web

echo "🚀 Iniciando proceso para REDCONTROL..."
echo "📦 Compilando aplicación..."
flutter build web --base-href "/redcontrol/" --dart-define=APP_MODE=redcontrol --release

if [ $? -eq 0 ]; then
    echo "✅ Compilación exitosa. Iniciando personalización de marca..."

    # Variables de marca
    APP_TITLE="RedControl"
    APP_TITLE_UPPER="REDCONTROL"
    APP_DESCRIPTION="Gestión de Red y Control Total de Saldos"

    echo "📝 Inyectando textos en index.html..."
    sed -i '' "s/{{APP_TITLE}}/$APP_TITLE/g" build/web/index.html
    sed -i '' "s/{{APP_TITLE_UPPER}}/$APP_TITLE_UPPER/g" build/web/index.html
    sed -i '' "s/{{APP_DESCRIPTION}}/$APP_DESCRIPTION/g" build/web/index.html

    echo "🖼️  Aplicando iconos de PWA (RedControl):"
    cp -v web/icons/redcontrol/* build/web/icons/

    echo "🧹 Limpiando directorios de marca del paquete final..."
    rm -rf build/web/icons/saldify
    rm -rf build/web/icons/redcontrol

    if [ -f "web/icons/redcontrol/favicon.png" ]; then
        cp -fv "web/icons/redcontrol/favicon.png" "build/web/favicon.png"
        echo "🎨 Favicon oficial copiado a la raíz (/favicon.png)."
    fi

    echo "✨ ¡Branding aplicado correctamente!"
    echo "🏁 Todo listo en: build/web/"
else
    echo "❌ Error: La compilación de Flutter falló. No se aplicaron los cambios de marca."
    exit 1
fi
