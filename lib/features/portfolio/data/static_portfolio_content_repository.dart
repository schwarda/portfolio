import 'package:flutter/widgets.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/portfolio_content.dart';
import '../domain/portfolio_content_repository.dart';

class StaticPortfolioContentRepository implements PortfolioContentRepository {
  const StaticPortfolioContentRepository();

  @override
  PortfolioContent contentFor(Locale locale) {
    if (_isSlovak(locale)) {
      return _contentSk;
    }
    return _contentEn;
  }

  bool _isSlovak(Locale locale) {
    return locale.languageCode.toLowerCase().startsWith('sk');
  }
}

const _skillTags = [
  'Flutter',
  'Dart',
  'Firebase',
  'Riverpod',
  'Bloc',
  'Clean Architecture',
  'REST APIs',
  'CI/CD',
  'Figma',
  'Codex',
  'GitHub Copilot',
  'Grok',
  'GitHub Actions',
  'Unit & Widget Tests',
];

const _contentSk = PortfolioContent(
  profile: ProfileData(
    name: 'Dávid',
    surname: 'Schwartz',
    initials: 'DS',
    title: 'Frontendový vývojár',
    location: 'Bratislava, Slovensko',
    about:
        'Navrhujem a vyvíjam moderné frontendové riešenia pre web aj mobil. Spájam '
        'produktové uvažovanie, čistú architektúru, výkon a UI, ktoré pôsobí premyslene.',
    email: PortfolioLinks.contactEmail,
    github: PortfolioLinks.github,
    linkedIn: PortfolioLinks.linkedIn,
  ),
  stats: [
    StatItem(value: '3+ roky', label: 'Skúsenosti s frontendovým vývojom'),
    StatItem(value: '5', label: 'Dokončených projektov'),
    StatItem(value: '100 %', label: 'Dôraz na UX a výkon'),
  ],
  focusCards: [
    FocusCardData(
      icon: FocusCardIcon.design,
      title: 'Frontend, ktorý funguje',
      description:
          'Návrh obrazoviek od wireframu po finálnu implementáciu s dôrazom na konzistenciu, zrozumiteľnosť a detail.',
      tone: FocusCardTone.blue,
    ),
    FocusCardData(
      icon: FocusCardIcon.performance,
      title: 'Výkon a stabilita',
      description:
          'Profilovanie, optimalizácia renderu a plynulé animácie aj pri náročnejších scénach.',
      tone: FocusCardTone.teal,
    ),
    FocusCardData(
      icon: FocusCardIcon.integrations,
      title: 'Integrácie a backend',
      description:
          'REST/GraphQL, autentifikácia, push notifikácie, analytika a napojenie na cloudové služby.',
      tone: FocusCardTone.coral,
    ),
  ],
  skillTags: _skillTags,
  timelineItems: [
    TimelineItem(
      period: '2023 - súčasnosť',
      role: 'Frontendový softvérový vývojár',
      company: 'TATRAMED s.r.o.',
      description:
          'Frontendový vývoj medicínskej aplikácie TOMOCON pre lekárov, vrátane UX/UI zlepšení a optimalizácie výkonu.',
    ),
    TimelineItem(
      period: '2025 - súčasnosť',
      role: 'Freelance full stack developer',
      company: 'Nová Jar',
      description:
          'Návrh a vývoj mobilnej aplikácie pre komunitu so zameraním na podcasty, e-knihy a komunitné udalosti.',
    ),
    TimelineItem(
      period: '2022 - 2023',
      role: 'Frontendový softvérový vývojár',
      company: 'Startup tím APONI s.r.o.',
      description:
          'Začiatok profesionálnej kariéry, refaktorovanie legacy častí aplikácie a postupné zavádzanie testov.',
    ),
  ],
  internalProfileNotes: [
    'Má 26 rokov, pochádza z Popradu a momentálne žije v Bratislave.',
    'Narodil sa 4. februára 2000.',
    'Študoval informatiku, no programovať sa naučil najmä ako samouk cez online zdroje, kurzy a prax.',
    'Strednú školu vyštudoval v Poprade v odbore elektrotechnika.',
    'Vysokú školu začal v Košiciach v odbore kyberbezpečnosť, no po bakalárskom ročníku nastúpil na plný úväzok.',
    'Programovaniu sa venuje od strednej školy, profesionálne pracuje od roku 2022.',
    'Hlavnou špecializáciou je frontendový vývoj webových a mobilných produktov, pričom silný kontext má vo Flutteri a rozumie aj backendovým integráciám a celému životnému cyklu aplikácií.',
    'Najradšej pracuje na projektoch, kde môže navrhovať a realizovať UX zlepšenia a optimalizovať výkon.',
    'Ideálny projekt je taký, kde má vplyv na UX, UI aj výkon a kde je dôležitá konzistentnosť kódu.',
    'Najsilnejší technický kontext má v modernom frontendovom vývoji, najmä vo Flutteri a Darte.',
    'Zakladá si na čistej architektúre, SOLID princípoch, výkone a konzistentnom UI na mobile aj desktope.',
    'Rozumie aj backendovým integráciám, najmä REST API, autentifikácii, analytike a cloudovým službám.',
    'V TATRAMED-e pracuje na medicínskom produkte TOMOCON pre lekárov, kde sa venuje najmä frontendu, navrhuje UX/UI zlepšenia, zavádza testy a optimalizuje výkon.',
    'Absolvoval uznávaný UX/UI kurz od SUXA: https://www.suxa.sk/uvod-do-ux',
    'Ako freelancer pre Novú Jar vyvíja mobilnú aplikáciu pre komunitu, podcasty, e-knihy a eventy, ktorú môže ukázať na pohovore.',
    'Pri technických odpovediach je vhodné zdôrazňovať pragmatický prístup, dopad na UX a udržateľnosť riešenia.',
    'Preferuje pracovný pomer ako zamestnanec a ideálne 100 % home office.',
    'Platové očakávanie je približne 2 500 až 3 000 EUR brutto mesačne.',
    'Má skúsenosti s agilným vývojom a Scrumom.',
    'Pri práci zvyčajne najprv zanalyzuje problém písomne alebo pomocou diagramu, potom ho rozdelí na menšie tasky.',
    'Veľkosť tasku sa snaží držať približne na jeden deň práce; ak je väčší, rozdelí ho na ešte menšie časti.',
    'Profesijne sa vníma ako medior frontend developer.',
    'Projekty rád ukáže na pohovore alebo pri úvodnom kontakte, ak o ne bude záujem.',
    'Používal napríklad Flutter, Dart, Riverpod, go_router, Firebase, Firestore, Firebase Storage, Firebase Analytics, Secure Storage, REST API, HTTP, epubx, flutter_inappwebview, share_plus, url_launcher, just_audio, Next.js, React, TypeScript, Sanity, GROQ, Styled Components, Tailwind CSS, Zod, Resend, Google Fonts, Vercel, GitHub Actions, Codex, GitHub Copilot a Grok.',
    'Pri otázkach na knižnice a nástroje má odpovedať stručným reprezentatívnym výberom; celý zoznam má rozpisovať len na výslovné vyžiadanie.',
    'Ak odpoveď nie je v profile, má uviesť, že Dávid na ňu rád odpovie na pohovore.',
    'Vo voľnom čase sa venuje cvičeniu s vlastnou váhou aj činkami, vareniu a lietaniu s dronom.',
    'Zaujímavosťou je zoskok z lietadla zo štyroch kilometrov, hoci pri pracovných témach to nebýva podstatné.',
    'Medzi silné stránky patrí analytické myslenie, schopnosť hľadať netradičné riešenia a dôraz na detail.',
  ],
);

const _contentEn = PortfolioContent(
  profile: ProfileData(
    name: 'Dávid',
    surname: 'Schwartz',
    initials: 'DS',
    title: 'Frontend developer',
    location: 'Bratislava, Slovakia',
    about:
        'I design and build modern frontend experiences for web and mobile. I care about '
        'product thinking, clean architecture, performance, and UI that feels deliberate.',
    email: PortfolioLinks.contactEmail,
    github: PortfolioLinks.github,
    linkedIn: PortfolioLinks.linkedIn,
  ),
  stats: [
    StatItem(value: '3+ years', label: 'Experience in frontend development'),
    StatItem(value: '5', label: 'Completed projects'),
    StatItem(value: '100%', label: 'Focus on UX and performance'),
  ],
  focusCards: [
    FocusCardData(
      icon: FocusCardIcon.design,
      title: 'Frontend that performs',
      description:
          'Screen design from wireframes to final implementation with a strong focus on consistency, clarity, and detail.',
      tone: FocusCardTone.blue,
    ),
    FocusCardData(
      icon: FocusCardIcon.performance,
      title: 'Performance and stability',
      description:
          'Profiling, render optimisation, and smooth animations even in more demanding scenarios.',
      tone: FocusCardTone.teal,
    ),
    FocusCardData(
      icon: FocusCardIcon.integrations,
      title: 'Integrations and backend',
      description:
          'REST/GraphQL, authentication, push notifications, analytics, and cloud integrations.',
      tone: FocusCardTone.coral,
    ),
  ],
  skillTags: _skillTags,
  timelineItems: [
    TimelineItem(
      period: '2023 - Present',
      role: 'Frontend developer',
      company: 'TATRAMED s.r.o.',
      description:
          'Frontend development of TOMOCON, a medical application for doctors, including UX/UI improvements and performance optimisation.',
    ),
    TimelineItem(
      period: '2025 - Present',
      role: 'Freelance full stack developer',
      company: 'Nova Jar',
      description:
          'Design and development of a mobile app for a community focused on podcasts, e-books, and community events.',
    ),
    TimelineItem(
      period: '2022 - 2023',
      role: 'Frontend developer',
      company: 'APONI startup team s.r.o.',
      description:
          'The start of his professional career, including refactoring legacy parts of the app and gradually introducing tests.',
    ),
  ],
  internalProfileNotes: [
    'He is 26 years old, comes from Poprad, and currently lives in Bratislava.',
    'He was born on 4 February 2000.',
    'He studied computer science, but he learned programming mainly as a self-taught developer through online resources, courses, and practice.',
    'He attended secondary school in Poprad, specialising in electrical engineering.',
    'He started university studies in Kosice in cybersecurity, but after the first bachelor year he moved into full-time work.',
    'He has been programming since secondary school and has worked professionally since 2022.',
    'His main specialisation is frontend development for web and mobile products, with strong Flutter experience and a solid understanding of backend integrations and the full application lifecycle.',
    'He prefers projects where he can design and implement UX improvements and optimise performance.',
    'The ideal project is one where he can influence UX, UI, and performance while maintaining code consistency.',
    'His strongest technical context is in modern frontend development, especially Flutter and Dart.',
    'He values clean architecture, SOLID principles, performance, and consistent UI across mobile and desktop.',
    'He also understands backend integrations, especially REST APIs, authentication, analytics, and cloud services.',
    'At TATRAMED, he works on TOMOCON, a medical product for doctors, focusing mainly on frontend work, UX/UI improvements, tests, and performance optimisation.',
    'He completed a respected UX/UI course by SUXA: https://www.suxa.sk/uvod-do-ux',
    'As a freelancer for Nova Jar, he is building a mobile app for a community, podcasts, e-books, and events, which he can present during interviews.',
    'In technical answers, it is useful to emphasise his pragmatic approach, UX impact, and long-term maintainability.',
    'He prefers full-time employment and ideally 100% remote work from home.',
    'His salary expectation is roughly EUR 2,500 to 3,000 gross per month.',
    'He has experience with agile development and Scrum.',
    'When working on a problem, he usually starts by analysing it in writing or by drawing a diagram and then breaks it down into smaller tasks.',
    'He tries to keep tasks to roughly one day of work; if a task grows beyond that, he splits it into smaller parts.',
    'He sees himself professionally as a mid-level frontend developer.',
    'He is happy to present his projects during an interview or early contact if there is interest.',
    'He has worked with tools and libraries such as Flutter, Dart, Riverpod, go_router, Firebase, Firestore, Firebase Storage, Firebase Analytics, Secure Storage, REST APIs, HTTP, epubx, flutter_inappwebview, share_plus, url_launcher, just_audio, Next.js, React, TypeScript, Sanity, GROQ, Styled Components, Tailwind CSS, Zod, Resend, Google Fonts, Vercel, GitHub Actions, Codex, GitHub Copilot, and Grok.',
    'When asked about libraries and tools, he should provide a concise representative summary instead of dumping the full list unless detailed enumeration is explicitly requested.',
    'If an answer is not in the profile, the response should say that Dávid will be happy to answer it during an interview.',
    'In his free time, he enjoys bodyweight training, weights, cooking, and flying drones.',
    'A personal detail: he has completed a skydive from four kilometres, although that is not usually relevant in professional discussions.',
    'His strengths include analytical thinking, an ability to find unconventional solutions, and strong attention to detail.',
  ],
);
