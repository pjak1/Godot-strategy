# Název hry: Tower Defense

## Shrnutí nápadu
Hráč staví obranné věže na herní mapě, aby zabránil vlnám nepřátel dostat se do cílového bodu. Každý nepřítel, který projde celou cestu, sníží počet životů hráče. Cílem je přežít všechny vlny a ubránit základnu. Hráč se snaží vyhrát úroveň hry tak, aby mu na konci zbylo co nejvíce peněz a životů.

## Herní mechaniky

- **Stavění věží**  
  Hráč má inventář s různými typy věží. Po výběru věže klikne na mapu a umístí ji na validní pozici mimo cesty. Umístění je indikováno graficky jako „valid“, „invalid“ nebo „potvrzené“.

- **Validace umístění**  
  Umístění věže není dovoleno:
  - mimo hranice mapy,
  - příliš blízko jiné věži,
  - příliš blízko cesty.

- **Nepřátelé**  
  Nepřátelé se spawnují ve vlnách. Každá vlna má definovaný typ a počet nepřátel. Každý typ nepřítele má:
  - rychlost,
  - zdraví,
  - odměnu za zabití.

- **Útok věží**  
  Věže mají určitou rychlost střelby, dosah a mohou mířit na cíle. Při dostatečném zarovnání hlaveň vystřelí na cíl. Cíle jsou detekovány podle skupiny `Enemy`.

- **Životy hráče a prohra**  
  Každý nepřítel, který dosáhne konce své cesty, odečte hráči životy. Pokud hráč přijde o všechny, hra končí.

- **Konec hry a vítězství**  
  Po úspěšném odražení všech vln se zobrazí menu s výpisem zbývajících peněz a životů. Hráč může zvolit `Restart` nebo `Quit`.

## Uživatelské rozhraní

- Inventář věží s tlačítkem pro zobrazení/skrytí
- Victory screen (finální stav peněz a životů hráče)
- Endgame menu (možnosti hru vypnout nebo restartovat)

## Možné rozšíření

- Více typů věží (AOE, zpomalovací, atd.)
- Více typů nepřátel (rychlí, silní, létající)
- Vylepšování věží
- Náhodně generované vlny
- Power-upy a upgrady
- Map editor
- Leaderboard