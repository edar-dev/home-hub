import '../domain/entities/language_code.dart';
import '../domain/entities/onboarding_step.dart';

/// Stringhe onboarding (IT / EN / ES).
String obString(
  OnboardingStep step,
  String field,
  LanguageCode lang,
) {
  final key = '${step.name}.$field';
  final table = _tableFor(lang);
  return table[key] ?? _tableFor(LanguageCode.it)[key] ?? key;
}

String obCommon(String field, LanguageCode lang) {
  final key = 'common.$field';
  final table = _tableFor(lang);
  return table[key] ?? _tableFor(LanguageCode.it)[key] ?? field;
}

/// Chiavi piatte (es. `tour.fab.title`, `settings.title`).
String tourLine(String key, LanguageCode lang) {
  final table = _tableFor(lang);
  return table[key] ?? _tableFor(LanguageCode.it)[key] ?? key;
}

Map<String, String> _tableFor(LanguageCode lang) {
  switch (lang) {
    case LanguageCode.en:
      return _en;
    case LanguageCode.es:
      return _es;
    case LanguageCode.it:
      return _it;
  }
}

const Map<String, String> _it = {
  'welcome.title': 'Benvenuto in The Organized Hive',
  'welcome.titlePrefix': 'Benvenuto in ',
  'welcome.titleBrand': 'The Organized Hive',
  'welcome.body':
      'Inventario, scadenze e spesa in un solo posto chiaro — per chi coordina la casa.',
  'welcome.startNow': 'Inizia Ora',
  'welcome.secondary': 'Accedi',
  'welcome.digitalCurator': 'Digital Curator',
  'welcome.smartCatalog': 'Catalogo Intelligente',
  'addProduct.title': 'Aggiungi prodotti',
  'addProduct.body':
      'Registra cosa hai in casa con quantità e scadenze. Tocca Prova ora per aprire il modulo.',
  'scanner.title': 'Scanner codici a barre',
  'scanner.body':
      'Associa rapidamente un codice al prodotto. Su web puoi inserirlo a mano.',
  'locations.title': 'Luoghi e posizioni',
  'locations.body':
      'Crea stanze e ripiani per ritrovare tutto al primo colpo.',
  'analytics.title': 'Analytics',
  'analytics.body':
      'Grafici e riepiloghi per capire cosa consumi di più.',
  'notifications.title': 'Notifiche',
  'notifications.body':
      'Promemoria su scadenze e digest giornaliero.',
  'firstSetup.title': 'Nome della casa',
  'firstSetup.body':
      'Come vuoi chiamare il tuo ambiente? Creeremo il primo luogo se non ne hai ancora.',
  'firstSetup.hint': 'Es. Casa, Appartamento…',
  'complete.title': 'Tutto pronto!',
  'complete.body': 'Hai completato il tour. Buon utilizzo!',
  'common.next': 'Avanti',
  'common.back': 'Indietro',
  'common.skip': 'Salta',
  'common.tryNow': 'Prova ora',
  'common.finish': 'Fine',
  'tour.fab.title': 'Aiuto e tour',
  'tour.fab.body':
      'Questo pulsante resta sempre disponibile. Tieni premuto per il tour guidato delle funzioni principali.',
  'tour.inventory.title': 'Inventario',
  'tour.inventory.body':
      'Qui vedi tutti i prodotti: cerca, filtra e aggiungi dal pulsante + sulla lista.',
  'tour.analytics.title': 'Analytics',
  'tour.analytics.body':
      'Apri il tab Analytics per grafici, sprechi e trend di consumo.',
  'tour.notifications.title': 'Notifiche',
  'tour.notifications.body':
      'Configura promemoria su scadenze e digest giornaliero da questo tab.',
  'settings.title': 'Onboarding e aiuto',
  'settings.skipAuto': 'Salta onboarding automatico',
  'settings.skipAutoSubtitle':
      'Non mostrare più il tour iniziale all’avvio (consigliato solo se conosci già l’app).',
  'settings.showOnUpdate': 'Mostra dopo aggiornamenti importanti',
  'settings.replayTour': 'Riproduci tour funzioni',
  'settings.resetDebug': 'Reimposta onboarding (solo debug)',
  'settings.animationSpeed': 'Velocità animazioni',
  'settings.language': 'Lingua tour',
  'settings.tooltips': 'Tooltip contestuali',
  'settings.analytics': 'Analytics anonimo (completamento)',
  'settings.save': 'Salva impostazioni',
  'help.quickTitle': 'Suggerimenti',
  'help.quickBody':
      'Usa le tab in basso per passare tra Inventario, Luoghi, Analytics e altro. Il pulsante Aiuto apre il tour quando tieni premuto.',
  'help.webTour': 'Tour funzioni',
};

const Map<String, String> _en = {
  'welcome.title': 'Welcome to The Organized Hive',
  'welcome.titlePrefix': 'Welcome to ',
  'welcome.titleBrand': 'The Organized Hive',
  'welcome.body':
      'Inventory, expiry, and shopping in one clear place — for whoever runs the home.',
  'welcome.startNow': 'Get started',
  'welcome.secondary': 'Sign in',
  'welcome.digitalCurator': 'Digital Curator',
  'welcome.smartCatalog': 'Smart catalog',
  'addProduct.title': 'Add products',
  'addProduct.body':
      'Log what you have with quantities and dates. Tap Try it to open the form.',
  'scanner.title': 'Barcode scanner',
  'scanner.body':
      'Link a barcode to a product quickly. On web you can type it manually.',
  'locations.title': 'Places & shelves',
  'locations.body':
      'Create rooms and shelves to find everything fast.',
  'analytics.title': 'Analytics',
  'analytics.body':
      'Charts and summaries to see what you use most.',
  'notifications.title': 'Notifications',
  'notifications.body':
      'Reminders for expiry and daily digest.',
  'firstSetup.title': 'Home name',
  'firstSetup.body':
      'What do you want to call your space? We’ll create the first location if needed.',
  'firstSetup.hint': 'e.g. Home, Apartment…',
  'complete.title': 'You’re set!',
  'complete.body': 'Tour complete. Enjoy organizing your home!',
  'common.next': 'Next',
  'common.back': 'Back',
  'common.skip': 'Skip',
  'common.tryNow': 'Try it',
  'common.finish': 'Done',
  'tour.fab.title': 'Help & tour',
  'tour.fab.body':
      'This button stays available. Long-press for a guided tour of main features.',
  'tour.inventory.title': 'Inventory',
  'tour.inventory.body':
      'Browse all products here: search, filter, and add from the + button on the list.',
  'tour.analytics.title': 'Analytics',
  'tour.analytics.body':
      'Open the Analytics tab for charts, waste insights and trends.',
  'tour.notifications.title': 'Notifications',
  'tour.notifications.body':
      'Configure expiry reminders and daily digest from this tab.',
  'settings.title': 'Onboarding & help',
  'settings.skipAuto': 'Skip automatic onboarding',
  'settings.skipAutoSubtitle':
      'Do not show the first-run tour on launch (only if you already know the app).',
  'settings.showOnUpdate': 'Show after major updates',
  'settings.replayTour': 'Replay feature tour',
  'settings.resetDebug': 'Reset onboarding (debug only)',
  'settings.animationSpeed': 'Animation speed',
  'settings.language': 'Tour language',
  'settings.tooltips': 'Contextual tooltips',
  'settings.analytics': 'Anonymous analytics (completion)',
  'settings.save': 'Save settings',
  'help.quickTitle': 'Tips',
  'help.quickBody':
      'Use the bottom tabs to switch between Inventory, Places, Analytics and more. Long-press Help to start the tour.',
  'help.webTour': 'Feature tour',
};

const Map<String, String> _es = {
  'welcome.title': 'Bienvenido a The Organized Hive',
  'welcome.titlePrefix': 'Bienvenido a ',
  'welcome.titleBrand': 'The Organized Hive',
  'welcome.body':
      'Inventario, caducidades y compras en un solo lugar claro — para quien organiza el hogar.',
  'welcome.startNow': 'Empezar',
  'welcome.secondary': 'Acceder',
  'welcome.digitalCurator': 'Digital Curator',
  'welcome.smartCatalog': 'Catálogo inteligente',
  'addProduct.title': 'Añadir productos',
  'addProduct.body':
      'Registra cantidades y fechas. Toca Probar para abrir el formulario.',
  'scanner.title': 'Escáner de códigos',
  'scanner.body':
      'Vincula un código al producto. En web puedes escribirlo a mano.',
  'locations.title': 'Lugares',
  'locations.body':
      'Crea habitaciones y estantes para encontrar todo rápido.',
  'analytics.title': 'Analítica',
  'analytics.body':
      'Gráficos y resúmenes de consumo.',
  'notifications.title': 'Notificaciones',
  'notifications.body':
      'Recordatorios de caducidad y resumen diario.',
  'firstSetup.title': 'Nombre del hogar',
  'firstSetup.body':
      '¿Cómo llamar a tu espacio? Crearemos el primer lugar si hace falta.',
  'firstSetup.hint': 'Ej. Casa…',
  'complete.title': '¡Listo!',
  'complete.body': 'Tour completado. ¡Buen uso!',
  'common.next': 'Siguiente',
  'common.back': 'Atrás',
  'common.skip': 'Omitir',
  'common.tryNow': 'Probar',
  'common.finish': 'Fin',
  'tour.fab.title': 'Ayuda y tour',
  'tour.fab.body':
      'Este botón siempre está disponible. Mantén pulsado para el tour guiado.',
  'tour.inventory.title': 'Inventario',
  'tour.inventory.body':
      'Aquí están todos los productos: busca, filtra y añade desde el +.',
  'tour.analytics.title': 'Analítica',
  'tour.analytics.body':
      'Abre la pestaña Analítica para gráficos y tendencias.',
  'tour.notifications.title': 'Notificaciones',
  'tour.notifications.body':
      'Configura recordatorios y resumen diario desde esta pestaña.',
  'settings.title': 'Onboarding y ayuda',
  'settings.skipAuto': 'Omitir onboarding automático',
  'settings.skipAutoSubtitle':
      'No mostrar el tour inicial al abrir (solo si ya conoces la app).',
  'settings.showOnUpdate': 'Mostrar tras actualizaciones importantes',
  'settings.replayTour': 'Repetir tour de funciones',
  'settings.resetDebug': 'Restablecer onboarding (solo depuración)',
  'settings.animationSpeed': 'Velocidad de animación',
  'settings.language': 'Idioma del tour',
  'settings.tooltips': 'Tooltips contextuales',
  'settings.analytics': 'Analytics anónimo (completado)',
  'settings.save': 'Guardar ajustes',
  'help.quickTitle': 'Sugerencias',
  'help.quickBody':
      'Usa las pestañas inferiores para cambiar de sección. Mantén pulsado Ayuda para el tour.',
  'help.webTour': 'Tour de funciones',
};
