# Utasapp 1.0.24+33 – fizetés, ETA, chat és teljes debug

- A meglévő Firebase Google- és e-mailes belépési/regisztrációs rendszer változatlan alapon maradt.
- A lezárt, még nem fizetett fuvar nem tűnik el, hanem fizetési állapotban marad.
- Készpénz kiválasztásakor nem indul `payments/init-transaction` kérés.
- A készpénzes mód a bookinghoz mentődik, majd az app a sofőr „Készpénz átvéve” visszaigazolására vár.
- `paid` státusz után eltűnik az aktív fuvar, megjelenik a Veszprémi Taxi köszönőüzenet, majd az értékelés.
- Az utas látja a sofőr vállalt érkezési idejét, a GPS-becslést és a távolságot.
- A chat kizárólag az aktuális bookinghoz tartozhat, polling fallbackkel.
- Teljes API-, UI-, route-, lifecycle-, booking-, ETA-, fizetés- és chattelemetria.
- Legfeljebb 1500 el nem küldött debugesemény tartósan megmarad appbezárás/hálózathiba után.
