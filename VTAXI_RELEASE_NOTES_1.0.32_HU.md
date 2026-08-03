# Sofőrapp 1.0.32+38 – robusztus fuvarfolyamat

- Öt fix sofőrfiók kiválasztása + 8 számjegyű PIN; nincs sofőrregisztráció és nincs Firebase Auth-belépés.
- A PIN-ek nincsenek beégetve az app forrásába.
- Ajánlat csak akkor tekinthető megjelenítettnek, amikor a widget ténylegesen kirajzolódott.
- Elfogadás csak friss, látható, azonos bookinghoz tartozó panelről és valódi pointer-down után indulhat.
- Kötelező érkezési vállalás: 10, 12, 15, 20, 25 vagy 30 perc.
- Egy régi lezárt fuvar státusza nem törölheti az új aktív fuvart.
- A lezárt, de még nem fizetett fuvar készpénzes képernyője újraindítás után helyreáll.
- Készpénz átvétele után csak `paid` backendválaszra szabadítja fel a sofőrt.
- ETA, GPS-becslés és távolság megjelenik a navigációs felületen.
- A chat kizárólag booking ID-val működik, polling fallbackkel.
- Teljes API-, UI-, route-, lifecycle-, offer-, státusz-, fizetés- és chattelemetria.
- Legfeljebb 1500 el nem küldött debugesemény tartósan megmarad appbezárás/hálózathiba után.
