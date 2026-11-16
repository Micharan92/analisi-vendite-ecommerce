# Analisi dei dati di vendita di un e-commerce

Query SQL sulle vendite di un sito: spesa dei clienti, fatturato dei prodotti, media per giorno della settimana e composizione degli ordini.

Lo script delle tabelle è quello del corso, salvato qui come `ecommerce.sql`.

## Come eseguirlo

In MySQL Workbench:

1. Crea uno schema vuoto e selezionalo con un doppio clic, finché il nome è in grassetto.
2. Apri `ecommerce.sql` ed eseguilo per intero. Crea `prodotto`, `cliente` e `ordini`.
3. Nello stesso schema apri `analisi_vendite.sql` ed eseguilo per intero.

Le query vanno lanciate una sola volta per schema: creano le viste `vendite` e `prodotti_per_ordine`.
