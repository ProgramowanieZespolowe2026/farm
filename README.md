# 🌾 Along the farm 

🔗 **[Strona informacyjna projektu](https://alongthefarm.netlify.app/)**

## 📖 Opis projektu
**Along the farm** Gra farmersko-ekonomiczna 2D RPG skupiona na spokojnym rozwoju i budowaniu własnej historii na opuszczonej farmie. Zaczynasz od niewielkiego skrawka ziemi, kilku grządek oraz podstawowych nasion. Z czasem przekształcasz zaniedbany teren w tętniące życiem gospodarstwo, podejmując decyzje, które wpływają na jego wygląd i rentowność.  
  
## ✨ Funkcjonalności (Features)
* **Zaawansowane Rolnictwo:** Korzystanie z narzędzi do orania ziemi (motyka), sadzenia nasion (np. marchewek), podlewania (konewka) oraz nawożenia upraw.
* **Hodowla zwierząt:** Budowa i obsługa stodół oraz kurników. Możliwość interakcji z różnymi zwierzętami (krowy, świnie, owce, kury).
* **Cykl Dnia i Nocy:** Płynny system zmiany pory dnia, który dynamicznie wpływa na oświetlenie i klimat w grze.
* **System Narzędzi:** Zmiana i używanie różnych narzędzi, w tym ścinanie drzew siekierą, używanie łopaty i zbieranie surowców.
* **Ekonomia i Sklep:** System handlu pozwalający na sprzedaż własnych plonów oraz otwierany sklep do zakupu zapasów i nasion.
* **Wydarzenia (World Events):** Generator losowych zdarzeń w świecie gry, które urozmaicają codzienną pracę na farmie.
* **Rozbudowane audio:** Dynamiczny system dźwięków kroków zależny od podłoża (trawa, ziemia, drewno) oraz efekty natury i interfejsu.

## 🛠️ Technologie i architektura
Gra została stworzona z naciskiem na czytelność kodu i optymalizację:
* **Silnik:** Godot Engine 4.x
* **Język programowania:** GDScript
* **Architektura Komponentowa:** W projekcie zastosowano podejście oparte na komponentach (ang. *Component-based architecture*). Wiele funkcjonalności, takich jak cykl dobowy (`DayNightCycleComponent`), podnoszenie przedmiotów (`CollectableComponent`) czy obsługa narzędzi (`ToolController`), to niezależne węzły. Ułatwia to dodawanie nowych mechanik bez ingerencji w główny kod obiektów.
* **TileMapy:** Zaawansowane wykorzystanie węzłów `TileMapLayer` do renderowania nieskończonej wody, trawy, zaoranej ziemi i elementów natury.
* **Dynamiczne Audio:** Zastosowanie scentralizowanego menedżera dźwięku (`AudioManager`), który zarządza różnymi szynami (Buses) dla muzyki i efektów specjalnych (SFX).

## 🚀 Uruchomienie gry

Aby uruchomić projekt na swoim komputerze, postępuj zgodnie z poniższymi instrukcjami:

1. **Pobierz silnik Godot:**
   Wejdź na oficjalną stronę [Godot Engine](https://godotengine.org/download) i pobierz wersję silnika dla swojego systemu (projekt obsługuje Godot 4.x).
2. **Pobierz repozytorium:**
   Sklonuj to repozytorium na swój dysk za pomocą gita lub pobierz je jako archiwum ZIP.
   Sklonuj to repozytorium na swój dysk za pomocą Gita, wpisując w terminalu poniższą komendę:
   ```bash
   git clone https://github.com/ProgramowanieZespolowe2026/farm.git
   ```
4. **Zaimportuj projekt do Godota:**
   - Otwórz silnik Godot i kliknij "Import".
   - Przejdź do pobranego repozytorium i wejdź do folderu `farm`.
   - Następnie przejdź do `godot` -> `farm-game` i kliknij `Select Current Folder`, aby go zaimportować.
5. **Otwórz mapę główną:**
   Gdy projekt się załaduje, w dolnym lewym panelu *FileSystem* (System plików) odszukaj i otwórz ścieżkę:
   `scenes -> ui -> main_menu.tscn` (otwórz klikając dwukrotnie).
6. **Uruchom grę:**
   Mając otwartą tę scenę, w prawym górnym rogu edytora kliknij przycisk **"Run Current Scene"** (ikona klapsa filmowego z przyciskiem Play) lub wciśnij klawisz `F6`.

## 👥 Twórcy
Projekt stworzony w ramach zajęć z programowania zespołowego.  
* **dr. Marta Burzańska** – Opiekun zespołu 
* **Mariusz Wilkosz** – Pomysłodawca i lider zespołu. Programista Godot i 2d artist  
* **Kacper Cieszyński** – Programista
* **Filip Jarocki** – Programista Godot i level-designer
* **Marek Roszak** – Programista
* **Szymon Koziełek** – Programista 
