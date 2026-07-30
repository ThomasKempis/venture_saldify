(function () {
  const docs = [
    {
      file: 'docu.html',
      title: 'Centro de documentacion',
    },
    {
      file: 'docu_001.html',
      title: 'Explicacion global',
      subtitle: 'De una cartera organizada a una Red de Redes comercial, medible, libre y capaz de crecer.',
    },
    {
      file: 'docu_002.html',
      title: 'Propuesta comercial',
      subtitle: 'Diferenciadores, potencial comercial, alcance funcional y alternativas de negociacion.',
    },
    {
      file: 'docu_003.html',
      title: 'Red de Redes',
      subtitle: 'Un modelo comercial donde cada negocio administra su red y puede formar parte de una red mayor.',
    },
    {
      file: 'docu_004.html',
      title: 'Modelo y evolucion',
      subtitle: 'Tipos de producto, estrategia freemium, etapas comerciales y camino de crecimiento.',
    },
    {
      file: 'docu_005.html',
      title: 'Arquitectura',
      subtitle: 'Reglas estructurales, validaciones, invariantes y responsabilidades tecnicas de la red.',
    },
  ];

  const path = window.location.pathname;
  const currentFile = decodeURIComponent(path.split('/').pop() || 'docu.html');
  const isDevelopmentDocs = path.includes('/documents/htmls/');
  const isHtmlsFolder = path.includes('/htmls/');
  const indexHref = isDevelopmentDocs || currentFile === 'docu.html'
    ? 'docu.html'
    : '../docu.html';
  const appHref = window.sessionStorage.getItem('saldify_documentation_return_url')
    || (isDevelopmentDocs ? '../../' : isHtmlsFolder ? '../' : './');
  const logoSrc = isDevelopmentDocs
    ? '../../assets/images/saldify/logo.png'
    : isHtmlsFolder
      ? '../assets/images/saldify/logo.png'
      : 'assets/images/saldify/logo.png';

  const currentIndex = Math.max(0, docs.findIndex((doc) => doc.file === currentFile));
  const prev = docs[(currentIndex - 1 + docs.length) % docs.length];
  const next = docs[(currentIndex + 1) % docs.length];
  const title = docs[currentIndex]?.title || document.title || 'Saldify';
  const subtitle = docs[currentIndex]?.subtitle || 'Documentacion operativa y comercial de Saldify.';

  function hrefFor(doc) {
    if (doc.file === 'docu.html') return indexHref;
    if (isDevelopmentDocs || isHtmlsFolder) return doc.file;
    return 'htmls/' + doc.file;
  }

  const shell = document.createElement('header');
  shell.className = 'docu-shell';
  shell.setAttribute('aria-label', 'Navegacion de documentacion');
  shell.innerHTML = `
    <a class="docu-shell-logo" href="${indexHref}" aria-label="Volver al indice">
      <img src="${logoSrc}" alt="">
    </a>
    <div class="docu-shell-title">
      <span>Saldify Docs</span>
      <strong>${title}</strong>
    </div>
    <a class="docu-shell-back-app" href="${appHref}">Volver a la app</a>
    <nav class="docu-shell-actions" aria-label="Acciones del documento">
      <a class="docu-shell-action" href="${indexHref}">Indice</a>
      <a class="docu-shell-action" href="${hrefFor(prev)}">Anterior</a>
      <a class="docu-shell-action" href="${hrefFor(next)}">Siguiente</a>
      <button class="docu-shell-action primary" type="button">Imprimir / Guardar PDF</button>
    </nav>
  `;

  shell.querySelector('button')?.addEventListener('click', function () {
    window.print();
  });

  document.body.insertBefore(shell, document.body.firstChild);

  const updateShellHeight = () => {
    const height = Math.ceil(shell.getBoundingClientRect().height);
    document.documentElement.style.setProperty('--docu-shell-height', `${height}px`);
  };

  updateShellHeight();
  window.addEventListener('resize', updateShellHeight);

  if ('ResizeObserver' in window) {
    new ResizeObserver(updateShellHeight).observe(shell);
  }

  if (currentFile !== 'docu.html' && !document.body.classList.contains('docu-native-cover')) {
    const cover = document.createElement('section');
    cover.className = 'docu-cover';
    cover.setAttribute('aria-label', 'Portada del documento');
    cover.innerHTML = `
      <div class="docu-cover-logo"><img src="${logoSrc}" alt=""></div>
      <div>
        <p class="docu-cover-eyebrow">Documento Saldify</p>
        <h1>${title}</h1>
        <p>${subtitle}</p>
      </div>
    `;
    shell.insertAdjacentElement('afterend', cover);
  }

  document.body.classList.add('docu-shell-ready');
  document.body.classList.remove('docu-shell-boot');
})();
