-- Analisi dei dati di vendita di un e-commerce
--
-- Eseguire questo file solo dopo aver importato ecommerce.sql
-- (lo script del repository GitHub) nello schema corretto.
-- Le query leggono le tabelle prodotto, cliente e ordini
-- create da quello script, nello stesso schema.
--
-- 1. Preparazione dei dati
-- 2. Analisi dei clienti
-- 3. Analisi dei prodotti
-- 4. Analisi temporale
-- 5. Analisi degli ordini


-- -----------------------------------------------------------------------------
-- 1. Preparazione dei dati
-- Unisco prodotto, cliente e ordini.
-- Una riga del risultato è un pezzo venduto: email del cliente,
-- nome e prezzo del prodotto, data dell'ordine.
-- La vista memorizza la join e viene riletta nelle fasi successive.
-- -----------------------------------------------------------------------------

create view vendite as
select
    cliente.id as id_cliente,
    cliente.email,
    prodotto.id as id_prodotto,
    prodotto.nome as nome_prodotto,
    prodotto.prezzo,
    ordini.data as data_ordine
from ordini
inner join cliente
    on ordini.id_cliente = cliente.id
inner join prodotto
    on ordini.id_prodotto = prodotto.id;

select
    id_cliente,
    email,
    id_prodotto,
    nome_prodotto,
    prezzo,
    data_ordine
from vendite
order by
    data_ordine,
    id_cliente;


-- -----------------------------------------------------------------------------
-- 2. Analisi dei clienti
-- Spesa totale di ogni cliente: somma dei prezzi dei prodotti acquistati.
-- L'elenco è ordinato dalla spesa più alta. La prima riga è chi ha speso
-- di più, il cliente da tenere presente per il programma fedeltà.
-- -----------------------------------------------------------------------------

select
    id_cliente,
    email,
    sum(prezzo) as spesa_totale
from vendite
group by
    id_cliente,
    email
order by spesa_totale desc;


-- -----------------------------------------------------------------------------
-- 3. Analisi dei prodotti
-- Fatturato di ogni prodotto: somma dei prezzi delle sue vendite.
-- numero_vendite conta i pezzi. La classifica è sul fatturato:
-- la prima riga è il best-seller.
-- -----------------------------------------------------------------------------

select
    id_prodotto,
    nome_prodotto,
    count(*) as numero_vendite,
    sum(prezzo) as fatturato_totale
from vendite
group by
    id_prodotto,
    nome_prodotto
order by fatturato_totale desc;


-- -----------------------------------------------------------------------------
-- 4. Analisi temporale
-- Prima calcolo il fatturato di ogni data.
-- Poi, su quei totali, calcolo la media per giorno della settimana.
-- dayofweek è la funzione di MySQL: 1 è domenica, 7 è sabato.
-- Il case when scrive il nome del giorno.
-- Nella seconda query la prima riga è il giorno con la media più alta.
-- numero_date dice su quante date è calcolata quella media.
-- -----------------------------------------------------------------------------

select
    data_ordine,
    case dayofweek(data_ordine)
        when 1 then 'Domenica'
        when 2 then 'Lunedì'
        when 3 then 'Martedì'
        when 4 then 'Mercoledì'
        when 5 then 'Giovedì'
        when 6 then 'Venerdì'
        when 7 then 'Sabato'
    end as giorno_settimana,
    sum(prezzo) as fatturato_giorno
from vendite
group by
    data_ordine,
    giorno_settimana
order by data_ordine;

select
    case numero_giorno
        when 1 then 'Domenica'
        when 2 then 'Lunedì'
        when 3 then 'Martedì'
        when 4 then 'Mercoledì'
        when 5 then 'Giovedì'
        when 6 then 'Venerdì'
        when 7 then 'Sabato'
    end as giorno_settimana,
    numero_date,
    fatturato_medio_giornaliero
from (
    select
        dayofweek(data_ordine) as numero_giorno,
        count(*) as numero_date,
        cast(avg(fatturato_giorno) as decimal(10, 2)) as fatturato_medio_giornaliero
    from (
        select
            data_ordine,
            sum(prezzo) as fatturato_giorno
        from vendite
        group by data_ordine
    ) as fatturato_per_data
    group by numero_giorno
) as media_per_giorno
order by
    fatturato_medio_giornaliero desc,
    numero_giorno;


-- -----------------------------------------------------------------------------
-- 5. Analisi degli ordini
-- In ordini non c'è un codice ordine: c'è un prodotto, un cliente e una data.
-- Un ordine è l'insieme delle righe con lo stesso cliente e la stessa data.
-- numero_prodotti è quanti pezzi contiene.
-- La media e la distribuzione si calcolano su questi ordini.
-- -----------------------------------------------------------------------------

create view prodotti_per_ordine as
select
    id_cliente,
    email,
    data_ordine,
    count(*) as numero_prodotti
from vendite
group by
    id_cliente,
    email,
    data_ordine;

select
    id_cliente,
    email,
    data_ordine,
    numero_prodotti
from prodotti_per_ordine
order by data_ordine;

select
    count(*) as numero_ordini,
    cast(avg(numero_prodotti) as decimal(10, 2)) as media_prodotti_per_ordine
from prodotti_per_ordine;

select
    numero_prodotti,
    count(*) as numero_ordini
from prodotti_per_ordine
group by numero_prodotti
order by numero_prodotti;
