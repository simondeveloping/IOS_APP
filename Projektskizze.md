# Gruppe

Simon Pham, Matr.Nr 3646757
Mike Jenke, Matr.Nr 3649732

# Git

Der Quellcode des Projekts wird auf GitHub gehostet und ist unter den folgenden Links erreichbar:

- **HTTPS:** `https://github.com/simondeveloping/IOS_APP.git`
- **SSH:** `git@github.com:simondeveloping/IOS_APP.git`

# Idee

Die geplante iOS-Applikation digitalisiert und modernisiert das klassische Konzept der Nachbarschaftshilfe. Im Gegensatz zu herkömmlichen Plattformen, die sich oft nur auf den unmittelbaren Wohnort beschränken, erweitert diese App den Radius und vernetzt Menschen auch über die direkte Nachbarschaft hinaus. Ziel ist es, eine unkomplizierte, sichere und vertrauenswürdige Plattform für alltägliche Dienstleistungen und Gefälligkeiten zu schaffen.

### Kernfunktionen & Ablauf

#### 1. Rollenverteilung (Auftraggeber & Helfer)

Nutzer können sich auf der Plattform flexibel bewegen und primär zwei Rollen einnehmen:

- **Auftraggeber (Hilfesuchende):** Nutzer können unkompliziert kleine Jobs oder Alltagsaufgaben als Inserat hochladen (z. B. _„Hilfe beim Glühbirne wechseln“, „Einkauf erledigen“, „Möbelstück tragen“_).
- **Auftragnehmer (Helfer):** Andere Nutzer können diese Inserate in ihrer Umgebung (bzw. in dem erweiterten Radius) einsehen und entscheiden, ob sie den Job annehmen möchten.

#### 2. Matchmaking & Auftragsannahme

Sobald ein Auftraggeber einen Job veröffentlicht hat, können interessierte Helfer diesen über die App anfragen oder direkt annehmen. Der Auftraggeber hat jederzeit die volle Kontrolle darüber, wem er die Aufgabe anvertraut.

#### 3. Innovative Validierung per QR-Code

Um Sicherheit und Verbindlichkeit für beide Seiten zu garantieren, setzt die App auf einen smarten Abschluss-Prozess: Sobald die Aufgabe vor Ort erledigt wurde, generiert die App einen individuellen QR-Code. Dieser muss von beiden Parteien (Auftraggeber und Helfer) mit dem Smartphone gescannt werden. Erst durch diesen beidseitigen Scan wird der Job im System offiziell als „erfolgreich abgeschlossen“ validiert.

#### 4. Bewertungs- und Reputationssystem

Nach der erfolgreichen QR-Code-Validierung schaltet die App die Bewertungsfunktion frei. Beide Parteien können sich gegenseitig bewerten und Feedback hinterlassen. Dies fördert ein respektvolles Miteinander, baut Vertrauen innerhalb der Community auf und hilft zukünftigen Nutzern bei der Auswahl zuverlässiger Helfer oder Auftraggeber.

# Anwendungsfälle und Anforderungen

Aus diesen Anwendungsfällen leiten sich die Anforderungen an die App ab:  
- Registrierung und Anmeldung von Nutzern.  
- Ein Auftraggeber erstellt einen Auftrag.  
- Ein Helfer sucht nach Aufträgen.  
- Ein Helfer schickt eine Chat-Anfrage für den Auftrag oder nimmt diesen direkt an.  
- Kommunikation zwischen Auftraggeber und Helfer.  
- Bestätigung eines Auftrages per QR-Code.  
- Bewertung nach einem Auftrag abgeben.  
- Reputation eines Benutzers prüfen.
## Funktional
- Es gibt die Möglichkeit zur Benutzerregistrierung und Anmeldung.  
- Benutzerprofile verwalten.  
- Möglichkeit zum Erstellen, Bearbeiten und Löschen von Aufträgen  
- Aufträge anzeigen und nach verschiedenen Kriterien filtern können  
- Auftragsanfragen verwalten.  
- Push-Benachrichtigungen versenden.  
- Chatfunktion für die Kommunikation zwischen den Nutzern bereitstellen.    
- QR-Codes erzeugen und scannen.  
- Aufträge nach QR-Bestätigung abschließen.  
- Bewertungen verwalten.  
- Reputationswerte berechnen.  
- Missbrauch melden können.  
- Nutzer sperren können (Admin-Funktion).

## Nicht-Funktional
- Sicherheit, z.B. dass Passwörter verschlüsselt gespeichert werden und die Kommunikation verschlüsselt stattfindet.

- Performance, z.B. dass Suchanfragen und Auftragslisten innerhalb von wenigen Sekunden geladen werden und Benachrichtigungen zeitnah zugestellt werden. 

- Zuverlässigkeit, z.B. dass das System eine hohe Verfügbarkeit bietet und keine Auftrags- oder Nutzerdaten verloren gehen.

- Benutzerfreundlichkeit, z.B. dass die App intuitiv bedienbar ist und ein Auftrag mit wenigen Schritten erstellt werden kann.

- Skalierbarkeit, z.B. dass die App auch bei einer steigenden Anzahl von Nutzern und Aufträgen performant bleibt.

- Wartbarkeit, z.B. dass der Quellcode modular aufgebaut ist und Erweiterungen oder Fehlerbehebungen einfach umgesetzt werden können.

- Kompatibilität, z.B. dass die Anwendung auf aktuellen iOS-Geräten und verschiedenen Bildschirmgrößen funktioniert.

- Verfügbarkeit, z.B. dass die App rund um die Uhr nutzbar ist und geplante Ausfälle auf ein Minimum reduziert werden.

- Datenintegrität, z.B. dass Bewertungen, Aufträge und Nutzerinformationen korrekt gespeichert und nicht unbeabsichtigt verändert (manipuliert) werden können.


# Konzept und geplanter Aufbau
## Konzept und geplanter Aufbau

Die App ist als modulare iOS-Anwendung (MVVM-Architektur) aufgebaut. Die wesentlichen Komponenten sind:

- Benutzerverwaltung (Registrierung, Login, Profilmanagement)
- Auftragsverwaltung (Erstellung, Anzeige, Bearbeitung von Hilfsaufträgen)
- Matching- und Vermittlungslogik (Annahme und Zuweisung von Aufträgen)
- Kommunikationsmodul (Chat zwischen Nutzern)
- QR-Code-Service zur Auftragsvalidierung
- Bewertungs- und Reputationssystem
- Backend-Service zur Datenverwaltung und Geschäftslogik

Dabei wird die Anbindung an eine Datenbank erforderlich, um die Daten verwalten zu können. Zusätzlich wird eine Server-Komponente erforderlich, um bestimmte Komponenten, wie die Benutzerverwaltung, zu ermöglichen. Dabei wird eine REST-Schnittstelle verwendet.

# Arbeitspakete und Aufteilung

Die Verantwortlichkeit wird im Wesentlichen wie folgt aufgeteilt:  
• X: iOS-App (Frontend), UI/UX, App-Architektur.  
• Y: Backend (Spring Boot), Datenbank, REST-API.

Im Einzelnen sind folgende Arbeitspakete zu realisieren:

• Konzeption der Systemarchitektur (Client-Server-Modell, REST-Schnittstellen, Datenfluss zwischen App und Backend).

• Entwicklung des Datenmodells für Nutzer, Aufträge, Bewertungen und Statusinformationen.

• Implementierung der Benutzerverwaltung (Registrierung, Login, Profilverwaltung, Authentifizierung).

• Implementierung der Auftragsverwaltung (Erstellen, Anzeigen, Bearbeiten und Löschen von Hilfsaufträgen).

• Entwicklung des Matching- und Vermittlungssystems für die Zuordnung von Helfern zu Aufträgen.

• Implementierung eines Kommunikationssystems (Chat zwischen Auftraggeber und Helfer).

• Entwicklung eines QR-Code-basierten Validierungsprozesses zur Bestätigung abgeschlossener Aufträge.

• Implementierung des Bewertungs- und Reputationssystems zur gegenseitigen Bewertung der Nutzer.

• Entwicklung der REST-API im Backend zur Bereitstellung aller benötigten Funktionen für die iOS-App.

• Implementierung der iOS-Client-Anwendung inklusive Navigation und Screen-Struktur.

• Durchführung von Tests.

# Milestones

# Ausblick

# Anhang
