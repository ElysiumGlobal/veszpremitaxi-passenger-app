# VTaxi Passenger 1.0.38+48

- Magyar az elsődleges és egyetlen aktív locale.
- Backendről letölthető, cache-elt `hu_app.json` nyelvi réteg.
- Offline esetben a bevált beépített magyar szövegek maradnak.
- A távoli nyelvi fájl hibája nem blokkolhatja az app indulását.
- Wallet és fuvarvégi settlement saját VTaxi-szövegei központi kulcsokra kerültek.
- A settlement kezeli a `terminal` fizetési mód magyar címkéjét is.
- A bizonyított booking/payment lifecycle nem változott.
